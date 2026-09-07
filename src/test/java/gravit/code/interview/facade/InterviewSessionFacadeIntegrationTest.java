package gravit.code.interview.facade;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewAnswerStatus;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.domain.InterviewSessionTopic;
import gravit.code.interview.domain.InterviewStack;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interview.repository.InterviewSessionTopicRepository;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_STACK_NOT_ALLOWED;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.생성_요청;
import static gravit.code.interview.fixture.InterviewSessionFixture.생성_요청_공통CS;
import static gravit.code.interview.fixture.InterviewSessionFixture.생성_요청_직군;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.문제_여러건;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.비활성_문제_여러건;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewSessionFacadeIntegrationTest {

    private static final long USER_ID = 1L;
    private static final int QUESTION_COUNT = 5;
    private static final int ACCURACY_MAX_SCORE = 70;
    private static final int STRUCTURE_MAX_SCORE = 15;
    private static final int CLARITY_MAX_SCORE = 15;
    private static final int ENOUGH_QUESTIONS = 10;

    @Autowired
    private InterviewSessionFacade interviewSessionFacade;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewSessionTopicRepository interviewSessionTopicRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    private void 문제를_채운다(
            InterviewDifficulty difficulty,
            int countPerTopic,
            InterviewTopic... topics
    ) {
        for (InterviewTopic topic : topics) {
            interviewQuestionRepository.saveAll(문제_여러건(topic, difficulty, countPerTopic));
        }
    }

    private List<InterviewAnswer> 답안들(long sessionId) {
        return interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId);
    }

    private List<InterviewTopic> 세션_주제들(long sessionId) {
        return interviewSessionTopicRepository.findAll().stream()
                .filter(sessionTopic -> sessionTopic.getSessionId() == sessionId)
                .map(InterviewSessionTopic::getTopic)
                .toList();
    }

    private Map<InterviewTopic, Long> 태그별_출제_수(long sessionId) {
        Map<Long, InterviewTopic> questionIdToTopic = interviewQuestionRepository.findAll().stream()
                .collect(Collectors.toMap(InterviewQuestion::getId, InterviewQuestion::getTopic));

        return 답안들(sessionId).stream()
                .collect(Collectors.groupingBy(
                        answer -> questionIdToTopic.get(answer.getQuestionId()),
                        Collectors.counting()
                ));
    }

    @Nested
    @DisplayName("세션을 생성할 때")
    class Create {

        @Test
        void 공통CS_세션과_주제와_답안을_함께_만든다() {
            // given
            문제를_채운다(InterviewDifficulty.NORMAL, ENOUGH_QUESTIONS,
                    InterviewTopic.ALGORITHM, InterviewTopic.NETWORK);
            InterviewSessionCreateRequest request = 생성_요청_공통CS(
                    InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM, InterviewTopic.NETWORK);

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.create(USER_ID, request);

            // then
            InterviewSession session = interviewSessionRepository.findById(response.sessionId()).orElseThrow();
            List<InterviewAnswer> answers = 답안들(response.sessionId());

            assertSoftly(softly -> {
                softly.assertThat(session.getStatus()).isEqualTo(InterviewSessionStatus.IN_PROGRESS);
                softly.assertThat(session.getAttemptCount()).isEqualTo(1L);
                softly.assertThat(session.getAccuracyMaxScore()).isEqualTo(ACCURACY_MAX_SCORE);
                softly.assertThat(session.getStructureMaxScore()).isEqualTo(STRUCTURE_MAX_SCORE);
                softly.assertThat(session.getClarityMaxScore()).isEqualTo(CLARITY_MAX_SCORE);
                softly.assertThat(session.getStack()).isNull();

                softly.assertThat(세션_주제들(response.sessionId()))
                        .containsExactlyInAnyOrder(InterviewTopic.ALGORITHM, InterviewTopic.NETWORK);

                softly.assertThat(answers).hasSize(QUESTION_COUNT);
                softly.assertThat(answers).allSatisfy(answer ->
                        assertThat(answer.getStatus()).isEqualTo(InterviewAnswerStatus.PENDING));
                softly.assertThat(answers.stream().map(InterviewAnswer::getDisplayOrder))
                        .containsExactly(1, 2, 3, 4, 5);
                softly.assertThat(answers.stream().map(InterviewAnswer::getQuestionId))
                        .doesNotHaveDuplicates();
            });
        }

        @Test
        void 공통CS_출제_수가_배분과_일치한다() {
            // given
            문제를_채운다(InterviewDifficulty.NORMAL, ENOUGH_QUESTIONS,
                    InterviewTopic.ALGORITHM, InterviewTopic.NETWORK);
            InterviewSessionCreateRequest request = 생성_요청_공통CS(
                    InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM, InterviewTopic.NETWORK);

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.create(USER_ID, request);

            // then
            assertThat(태그별_출제_수(response.sessionId()).values())
                    .containsExactlyInAnyOrder(3L, 2L);
        }

        @Test
        void 직군_세션은_스택_구성_태그를_주제로_남기고_공통_언어_프레임워크_순으로_출제한다() {
            // given
            문제를_채운다(InterviewDifficulty.HARD, ENOUGH_QUESTIONS,
                    InterviewTopic.SERVER_COMMON, InterviewTopic.JAVA, InterviewTopic.SPRING_BOOT);
            InterviewSessionCreateRequest request = 생성_요청_직군(
                    InterviewDifficulty.HARD, InterviewStack.JAVA_SPRING_BOOT);

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.create(USER_ID, request);

            // then
            Map<Long, InterviewTopic> questionIdToTopic = interviewQuestionRepository.findAll().stream()
                    .collect(Collectors.toMap(InterviewQuestion::getId, InterviewQuestion::getTopic));
            List<InterviewTopic> orderedTopics = 답안들(response.sessionId()).stream()
                    .sorted(Comparator.comparingInt(InterviewAnswer::getDisplayOrder))
                    .map(answer -> questionIdToTopic.get(answer.getQuestionId()))
                    .toList();

            assertSoftly(softly -> {
                softly.assertThat(세션_주제들(response.sessionId())).containsExactlyInAnyOrder(
                        InterviewTopic.SERVER_COMMON, InterviewTopic.JAVA, InterviewTopic.SPRING_BOOT);
                softly.assertThat(orderedTopics).containsExactly(
                        InterviewTopic.SERVER_COMMON,
                        InterviewTopic.JAVA,
                        InterviewTopic.JAVA,
                        InterviewTopic.SPRING_BOOT,
                        InterviewTopic.SPRING_BOOT
                );
                softly.assertThat(interviewSessionRepository.findById(response.sessionId()).orElseThrow().getStack())
                        .isEqualTo(InterviewStack.JAVA_SPRING_BOOT);
            });
        }

        @Test
        void 두_번째_생성이면_시도_차수가_2가_된다() {
            // given
            문제를_채운다(InterviewDifficulty.NORMAL, ENOUGH_QUESTIONS, InterviewTopic.ALGORITHM);
            InterviewSessionCreateRequest request = 생성_요청_공통CS(
                    InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM);
            interviewSessionFacade.create(USER_ID, request);

            // when
            InterviewSessionCreateResponse second = interviewSessionFacade.create(USER_ID, request);

            // then
            assertThat(interviewSessionRepository.findById(second.sessionId()).orElseThrow().getAttemptCount())
                    .isEqualTo(2L);
        }

        @Test
        void 취소되거나_채점_실패한_세션도_시도_차수를_소비한다() {
            // given
            interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.ABANDONED));
            interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.GRADING_FAILED));
            문제를_채운다(InterviewDifficulty.NORMAL, ENOUGH_QUESTIONS, InterviewTopic.ALGORITHM);

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.create(
                    USER_ID, 생성_요청_공통CS(InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM));

            // then
            assertThat(interviewSessionRepository.findById(response.sessionId()).orElseThrow().getAttemptCount())
                    .isEqualTo(2L);
        }

        @Test
        void 다른_난이도_문제만_있으면_예외를_던지고_아무것도_남기지_않는다() {
            // given
            문제를_채운다(InterviewDifficulty.EASY, ENOUGH_QUESTIONS, InterviewTopic.ALGORITHM);
            InterviewSessionCreateRequest request = 생성_요청_공통CS(
                    InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM);

            // when & then
            assertThatThrownBy(() -> interviewSessionFacade.create(USER_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);

            assertSoftly(softly -> {
                softly.assertThat(interviewSessionRepository.findAll()).isEmpty();
                softly.assertThat(interviewSessionTopicRepository.findAll()).isEmpty();
                softly.assertThat(interviewAnswerRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 태그_하나만_몫에_미달해도_예외를_던지고_아무것도_남기지_않는다() {
            // given
            문제를_채운다(InterviewDifficulty.NORMAL, ENOUGH_QUESTIONS, InterviewTopic.ALGORITHM);
            문제를_채운다(InterviewDifficulty.NORMAL, 1, InterviewTopic.NETWORK);
            InterviewSessionCreateRequest request = 생성_요청_공통CS(
                    InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM, InterviewTopic.NETWORK);

            // when & then
            assertThatThrownBy(() -> interviewSessionFacade.create(USER_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);

            assertSoftly(softly -> {
                softly.assertThat(interviewSessionRepository.findAll()).isEmpty();
                softly.assertThat(interviewSessionTopicRepository.findAll()).isEmpty();
                softly.assertThat(interviewAnswerRepository.findAll()).isEmpty();
            });
        }

        @Test
        void 비활성_문제는_뽑히지_않는다() {
            // given
            interviewQuestionRepository.saveAll(비활성_문제_여러건(InterviewTopic.ALGORITHM, InterviewDifficulty.NORMAL, 10));
            List<InterviewQuestion> activeQuestions = interviewQuestionRepository.saveAll(
                    문제_여러건(InterviewTopic.ALGORITHM, InterviewDifficulty.NORMAL, QUESTION_COUNT));
            List<Long> activeQuestionIds = activeQuestions.stream().map(InterviewQuestion::getId).toList();

            // when
            InterviewSessionCreateResponse response = interviewSessionFacade.create(
                    USER_ID, 생성_요청_공통CS(InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM));

            // then
            assertThat(답안들(response.sessionId()).stream().map(InterviewAnswer::getQuestionId))
                    .containsExactlyInAnyOrderElementsOf(activeQuestionIds);
        }

        @Test
        void 활성_문제가_부족하면_비활성이_많아도_예외를_던진다() {
            // given
            interviewQuestionRepository.saveAll(비활성_문제_여러건(InterviewTopic.ALGORITHM, InterviewDifficulty.NORMAL, 10));
            interviewQuestionRepository.saveAll(문제_여러건(InterviewTopic.ALGORITHM, InterviewDifficulty.NORMAL, 4));

            // when & then
            assertThatThrownBy(() -> interviewSessionFacade.create(
                    USER_ID, 생성_요청_공통CS(InterviewDifficulty.NORMAL, InterviewTopic.ALGORITHM)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_QUESTION_POOL_INSUFFICIENT);
        }

        @Test
        void 모드_조합이_틀리면_세션이_생기지_않는다() {
            // given
            문제를_채운다(InterviewDifficulty.NORMAL, ENOUGH_QUESTIONS, InterviewTopic.ALGORITHM);
            InterviewSessionCreateRequest request = 생성_요청(
                    InterviewInputType.TEXT,
                    InterviewMode.COMMON_CS,
                    InterviewDifficulty.NORMAL,
                    InterviewStack.JAVA_SPRING_BOOT,
                    List.of(InterviewTopic.ALGORITHM)
            );

            // when & then
            assertThatThrownBy(() -> interviewSessionFacade.create(USER_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_STACK_NOT_ALLOWED);

            assertThat(interviewSessionRepository.findAll()).isEmpty();
        }
    }
}
