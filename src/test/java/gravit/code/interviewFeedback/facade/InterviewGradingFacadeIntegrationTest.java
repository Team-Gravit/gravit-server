package gravit.code.interviewFeedback.facade;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interviewFeedback.domain.InterviewFeedback;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingInputDto;
import gravit.code.interviewFeedback.repository.InterviewFeedbackRepository;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.repository.InterviewQuestionConceptRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.StubInterviewGradingClient;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.repository.UserLeagueRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.개념;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.답변한_답안;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.무응답_답안;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.문제;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewGradingFacadeIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long UNKNOWN_SESSION_ID = 999L;
    private static final long UNIT_ID = 11L;
    private static final int QUESTION_COUNT = 5;
    private static final int ANSWERED_ACCURACY = 14;
    private static final int ANSWERED_STRUCTURE = 3;
    private static final int ANSWERED_CLARITY = 3;
    private static final int ANSWERED_DELIVERY = ANSWERED_STRUCTURE + ANSWERED_CLARITY;
    private static final String CONTENT_PREFIX = "답변 ";
    private static final String FAILING_CONTENT = CONTENT_PREFIX + 3;
    private static final String CONCEPT_SUFFIX = " 필수 개념";
    private static final LocalDateTime ANSWERED_AT = LocalDateTime.of(2026, 9, 1, 10, 0);
    private static final List<InterviewTopic> TOPICS = List.of(
            InterviewTopic.DATA_STRUCTURE,
            InterviewTopic.ALGORITHM,
            InterviewTopic.DATABASE,
            InterviewTopic.OPERATING_SYSTEM,
            InterviewTopic.NETWORK
    );

    @Autowired
    private InterviewGradingFacade interviewGradingFacade;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Autowired
    private InterviewQuestionConceptRepository interviewQuestionConceptRepository;

    @Autowired
    private InterviewFeedbackRepository interviewFeedbackRepository;

    @Autowired
    private StubInterviewGradingClient stubInterviewGradingClient;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserLeagueRepository userLeagueRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @BeforeEach
    void resetStub() {
        stubInterviewGradingClient.reset();
    }

    private InterviewSession 채점중_세션() {
        return interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.GRADING));
    }

    private List<InterviewQuestion> 저장된_문제_5개() {
        List<InterviewQuestion> questions = new ArrayList<>();
        for (InterviewTopic topic : TOPICS) {
            InterviewQuestion question = interviewQuestionRepository.save(문제(topic, UNIT_ID));
            interviewQuestionConceptRepository.save(
                    개념(question.getId(), topic.getDisplayName() + CONCEPT_SUFFIX, InterviewConceptType.ESSENTIAL, 1)
            );
            questions.add(question);
        }
        return questions;
    }

    private void 답안_저장(
            long sessionId,
            List<InterviewQuestion> questions,
            int answeredCount
    ) {
        List<InterviewAnswer> answers = new ArrayList<>();
        for (int index = 0; index < questions.size(); index++) {
            int displayOrder = index + 1;
            long questionId = questions.get(index).getId();
            if (index < answeredCount) {
                answers.add(답변한_답안(sessionId, questionId, displayOrder, CONTENT_PREFIX + displayOrder, ANSWERED_AT));
            } else {
                answers.add(무응답_답안(sessionId, questionId, displayOrder, ANSWERED_AT));
            }
        }
        interviewAnswerRepository.saveAll(answers);
    }

    private InterviewSession 세션(long sessionId) {
        return interviewSessionRepository.findById(sessionId).orElseThrow();
    }

    @Nested
    @DisplayName("채점할 때")
    class Grade {

        @Test
        void 모든_문항에_답변했으면_피드백_5건과_세션_점수를_저장하고_완료가_된다() {
            // given
            InterviewSession session = 채점중_세션();
            List<InterviewQuestion> questions = 저장된_문제_5개();
            답안_저장(session.getId(), questions, QUESTION_COUNT);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            InterviewSession graded = 세션(session.getId());
            List<InterviewFeedback> feedbacks = interviewFeedbackRepository.findAll();
            InterviewGradingInputDto firstInput = stubInterviewGradingClient.inputs().get(0);
            InterviewQuestion firstQuestion = questions.get(0);
            assertSoftly(softly -> {
                softly.assertThat(graded.getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(graded.getAccuracyScore()).isEqualTo(ANSWERED_ACCURACY * QUESTION_COUNT);
                softly.assertThat(graded.getDeliveryScore()).isEqualTo(ANSWERED_DELIVERY * QUESTION_COUNT);

                softly.assertThat(feedbacks).hasSize(QUESTION_COUNT);
                softly.assertThat(feedbacks).allSatisfy(feedback -> {
                    assertThat(feedback.getAccuracyScore()).isEqualTo(ANSWERED_ACCURACY);
                    assertThat(feedback.getStructureScore()).isEqualTo(ANSWERED_STRUCTURE);
                    assertThat(feedback.getClarityScore()).isEqualTo(ANSWERED_CLARITY);
                    assertThat(feedback.getAccuracyBaseRatio()).isEqualByComparingTo(new BigDecimal("1.000"));
                    assertThat(feedback.getAccuracyMultiplier()).isEqualByComparingTo(new BigDecimal("1.0"));
                    assertThat(feedback.getIrrelevantStatementCount()).isZero();
                    assertThat(feedback.getImprovementSuggestion()).isNotBlank();
                });

                softly.assertThat(stubInterviewGradingClient.callCount()).isEqualTo(QUESTION_COUNT);
                softly.assertThat(firstInput.questionContent()).isEqualTo(firstQuestion.getContent());
                softly.assertThat(firstInput.modelAnswer()).isEqualTo(firstQuestion.getModelAnswer());
                softly.assertThat(firstInput.concepts()).hasSize(1);
                softly.assertThat(firstInput.concepts().get(0).name()).isEqualTo(TOPICS.get(0).getDisplayName() + CONCEPT_SUFFIX);
                softly.assertThat(firstInput.answerContent()).isEqualTo(CONTENT_PREFIX + 1);
            });
        }

        @Test
        void 모든_문항이_무응답이면_AI를_호출하지_않고_0점으로_완료가_된다() {
            // given
            InterviewSession session = 채점중_세션();
            답안_저장(session.getId(), 저장된_문제_5개(), 0);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            InterviewSession graded = 세션(session.getId());
            List<InterviewFeedback> feedbacks = interviewFeedbackRepository.findAll();
            assertSoftly(softly -> {
                softly.assertThat(graded.getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(graded.getAccuracyScore()).isZero();
                softly.assertThat(graded.getDeliveryScore()).isZero();
                softly.assertThat(feedbacks).hasSize(QUESTION_COUNT);
                softly.assertThat(feedbacks).allSatisfy(feedback -> {
                    assertThat(feedback.getAccuracyScore()).isZero();
                    assertThat(feedback.getStructureScore()).isZero();
                    assertThat(feedback.getClarityScore()).isZero();
                    assertThat(feedback.getAccuracyBaseRatio()).isNull();
                    assertThat(feedback.getAccuracyMultiplier()).isNull();
                    assertThat(feedback.getIrrelevantStatementCount()).isNull();
                    assertThat(feedback.getImprovementSuggestion()).isNull();
                });
                softly.assertThat(stubInterviewGradingClient.callCount()).isZero();
            });
        }

        @Test
        void 무응답_문항은_AI를_호출하지_않고_답변한_문항만_판정한다() {
            // given
            InterviewSession session = 채점중_세션();
            답안_저장(session.getId(), 저장된_문제_5개(), 3);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            InterviewSession graded = 세션(session.getId());
            assertSoftly(softly -> {
                softly.assertThat(graded.getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(graded.getAccuracyScore()).isEqualTo(ANSWERED_ACCURACY * 3);
                softly.assertThat(graded.getDeliveryScore()).isEqualTo(ANSWERED_DELIVERY * 3);
                softly.assertThat(interviewFeedbackRepository.count()).isEqualTo(QUESTION_COUNT);
                softly.assertThat(stubInterviewGradingClient.callCount()).isEqualTo(3);
            });
        }

        @Test
        void 판정이_실패하면_채점_실패로_전이하고_피드백을_저장하지_않는다() {
            // given
            InterviewSession session = 채점중_세션();
            답안_저장(session.getId(), 저장된_문제_5개(), QUESTION_COUNT);
            stubInterviewGradingClient.failAlways();

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            InterviewSession failed = 세션(session.getId());
            assertSoftly(softly -> {
                softly.assertThat(failed.getStatus()).isEqualTo(InterviewSessionStatus.GRADING_FAILED);
                softly.assertThat(failed.getAccuracyScore()).isZero();
                softly.assertThat(failed.getDeliveryScore()).isZero();
                softly.assertThat(interviewFeedbackRepository.count()).isZero();
            });
        }

        @Test
        void 일부_문항만_실패해도_부분_저장_없이_채점_실패가_된다() {
            // given
            InterviewSession session = 채점중_세션();
            답안_저장(session.getId(), 저장된_문제_5개(), QUESTION_COUNT);
            stubInterviewGradingClient.respondWith(input -> {
                if (FAILING_CONTENT.equals(input.answerContent())) {
                    throw new RestApiException(CustomErrorCode.INTERVIEW_GRADING_FAILED);
                }
                return StubInterviewGradingClient.perfectJudgment(input);
            });

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.GRADING_FAILED);
                softly.assertThat(interviewFeedbackRepository.count()).isZero();
                softly.assertThat(stubInterviewGradingClient.callCount()).isEqualTo(3);
            });
        }

        @Test
        void 채점_중이_아닌_세션이면_예외_없이_아무것도_바꾸지_않는다() {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.IN_PROGRESS));
            답안_저장(session.getId(), 저장된_문제_5개(), QUESTION_COUNT);

            // when
            assertThatCode(() -> interviewGradingFacade.grade(session.getId())).doesNotThrowAnyException();

            // then
            assertSoftly(softly -> {
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.IN_PROGRESS);
                softly.assertThat(interviewFeedbackRepository.count()).isZero();
                softly.assertThat(stubInterviewGradingClient.callCount()).isZero();
            });
        }

        @Test
        void 없는_세션이면_예외_없이_끝난다() {
            // when & then
            assertThatCode(() -> interviewGradingFacade.grade(UNKNOWN_SESSION_ID)).doesNotThrowAnyException();
            assertThat(stubInterviewGradingClient.callCount()).isZero();
        }
    }

    @Nested
    @DisplayName("채점이 끝나면 보상을")
    class Reward {

        private static final int FULL_SCORE_REWARD = 30;
        private static final int NO_REWARD = 0;

        private User XP를_가진_유저(int xp) {
            User user = userFixture.일반_유저(1);
            ReflectionTestUtils.setField(user, "level", UserLevel.create(1, xp), UserLevel.class);
            return userRepository.save(user);
        }

        private void 브론즈3_리그_참여(
                User user,
                int lp
        ) {
            Season season = seasonFixture.진행중인_시즌("S1");
            League 브론즈3 = leagueFixture.브론즈_3();
            userLeagueFixture.참여(user, season, 브론즈3, lp);
        }

        private InterviewSession 답안이_저장된_채점중_세션(
                long userId,
                int answeredCount
        ) {
            InterviewSession session = interviewSessionRepository.save(상태_세션(userId, InterviewSessionStatus.GRADING));
            답안_저장(session.getId(), 저장된_문제_5개(), answeredCount);
            return session;
        }

        private User 유저(long userId) {
            return userRepository.findById(userId).orElseThrow();
        }

        private int 누적_LP(long userId) {
            return userLeagueRepository.findByUserId(userId).orElseThrow().getLp();
        }

        @Test
        void 모든_문항이_만점이면_XP와_LP를_30씩_지급한다() {
            // given
            User user = userFixture.일반_유저(1);
            브론즈3_리그_참여(user, 0);
            InterviewSession session = 답안이_저장된_채점중_세션(user.getId(), QUESTION_COUNT);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(유저(user.getId()).getLevel().getXp()).isEqualTo(FULL_SCORE_REWARD);
                softly.assertThat(누적_LP(user.getId())).isEqualTo(FULL_SCORE_REWARD);
            });
        }

        @Test
        void 모든_문항이_무응답이면_완료되지만_보상은_지급하지_않는다() {
            // given
            User user = userFixture.일반_유저(1);
            브론즈3_리그_참여(user, 0);
            InterviewSession session = 답안이_저장된_채점중_세션(user.getId(), 0);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(유저(user.getId()).getLevel().getXp()).isEqualTo(NO_REWARD);
                softly.assertThat(누적_LP(user.getId())).isEqualTo(NO_REWARD);
            });
        }

        @Test
        void 채점이_실패하면_보상을_지급하지_않는다() {
            // given
            User user = userFixture.일반_유저(1);
            브론즈3_리그_참여(user, 0);
            InterviewSession session = 답안이_저장된_채점중_세션(user.getId(), QUESTION_COUNT);
            stubInterviewGradingClient.failAlways();

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.GRADING_FAILED);
                softly.assertThat(유저(user.getId()).getLevel().getXp()).isEqualTo(NO_REWARD);
                softly.assertThat(누적_LP(user.getId())).isEqualTo(NO_REWARD);
            });
        }

        @Test
        void XP가_레벨_경계를_넘으면_레벨이_오른다() {
            // given - 90 + 30 = 120, 레벨 2 구간(100~199)
            User user = XP를_가진_유저(90);
            브론즈3_리그_참여(user, 0);
            InterviewSession session = 답안이_저장된_채점중_세션(user.getId(), QUESTION_COUNT);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            User updated = 유저(user.getId());
            assertSoftly(softly -> {
                softly.assertThat(updated.getLevel().getXp()).isEqualTo(120);
                softly.assertThat(updated.getLevel().getLevel()).isEqualTo(2);
            });
        }

        @Test
        void LP가_다음_리그_범위에_진입하면_승급한다() {
            // given - 90 + 30 = 120, 브론즈 2 구간(101~200)
            User user = userFixture.일반_유저(1);
            leagueFixture.브론즈_2();
            브론즈3_리그_참여(user, 90);
            InterviewSession session = 답안이_저장된_채점중_세션(user.getId(), QUESTION_COUNT);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(누적_LP(user.getId())).isEqualTo(120);
                softly.assertThat(userLeagueRepository.findUserLeagueNameByUserId(user.getId())).hasValue("브론즈 2");
            });
        }

        @Test
        void 유저_리그가_없어도_완료되고_XP는_지급한다() {
            // given
            User user = userFixture.일반_유저(1);
            InterviewSession session = 답안이_저장된_채점중_세션(user.getId(), QUESTION_COUNT);

            // when
            interviewGradingFacade.grade(session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(유저(user.getId()).getLevel().getXp()).isEqualTo(FULL_SCORE_REWARD);
                softly.assertThat(userLeagueRepository.existsByUserId(user.getId())).isFalse();
            });
        }
    }
}
