package gravit.code.interview.service;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.internal.InterviewQuestionHistoryDto;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interviewFeedback.repository.InterviewFeedbackRepository;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static gravit.code.interview.fixture.InterviewSessionFixture.미제출_답안;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.무응답_답안;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.무응답_피드백;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.미완료_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.완료_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.피드백;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.문제_여러건;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewAnswerQueryServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final int QUESTION_COUNT = 2;
    private static final int SESSION_SCORE = 0;
    private static final int STRUCTURE_SCORE = 3;
    private static final int CLARITY_SCORE = 3;
    private static final LocalDateTime OLDER = LocalDateTime.of(2025, 8, 1, 12, 0);
    private static final LocalDateTime NEWER = LocalDateTime.of(2025, 8, 3, 12, 0);

    @Autowired
    private InterviewAnswerQueryService interviewAnswerQueryService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewFeedbackRepository interviewFeedbackRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    private long firstQuestionId;
    private long secondQuestionId;

    @BeforeEach
    void setUp() {
        List<InterviewQuestion> questions = interviewQuestionRepository.saveAll(
                문제_여러건(InterviewTopic.ALGORITHM, InterviewDifficulty.NORMAL, QUESTION_COUNT));
        firstQuestionId = questions.get(0).getId();
        secondQuestionId = questions.get(1).getId();
    }

    private void 채점된_세션을_만든다(
            long userId,
            LocalDateTime startedAt,
            long questionId,
            int accuracyScore
    ) {
        InterviewSession session = interviewSessionRepository.save(
                완료_세션(userId, 1L, startedAt, SESSION_SCORE, SESSION_SCORE));
        InterviewAnswer answer = interviewAnswerRepository.save(
                미제출_답안(session.getId(), List.of(questionId)).get(0));
        interviewFeedbackRepository.save(피드백(answer.getId(), accuracyScore, STRUCTURE_SCORE, CLARITY_SCORE, null));
    }

    private void 점수_없는_세션을_만든다(
            long userId,
            LocalDateTime startedAt,
            InterviewSessionStatus status,
            List<Long> questionIds
    ) {
        InterviewSession session = interviewSessionRepository.save(
                미완료_세션(userId, 1L, startedAt, status));
        interviewAnswerRepository.saveAll(미제출_답안(session.getId(), questionIds));
    }

    @Nested
    @DisplayName("문제별 최근 출제 이력을 조회할 때")
    class GetQuestionIdToLatestHistory {

        @Test
        void 같은_문제가_여러_세션에_나오면_가장_최근_세션의_기록만_남긴다() {
            // given
            채점된_세션을_만든다(USER_ID, NEWER, firstQuestionId, 10);
            채점된_세션을_만든다(USER_ID, OLDER, firstQuestionId, 3);

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            InterviewQuestionHistoryDto history = result.get(firstQuestionId);
            assertSoftly(softly -> {
                softly.assertThat(result).hasSize(1);
                softly.assertThat(history.presentedAt()).isEqualTo(NEWER);
                softly.assertThat(history.accuracyScore()).isEqualTo(10);
            });
        }

        @Test
        void 취소한_세션에만_나온_문제는_결과에_없다() {
            // given
            점수_없는_세션을_만든다(USER_ID, NEWER, InterviewSessionStatus.ABANDONED, List.of(firstQuestionId));

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 가장_최근_세션이_취소됐으면_그_전_기록을_쓴다() {
            // given
            채점된_세션을_만든다(USER_ID, OLDER, firstQuestionId, 3);
            점수_없는_세션을_만든다(USER_ID, NEWER, InterviewSessionStatus.ABANDONED, List.of(firstQuestionId));

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            InterviewQuestionHistoryDto history = result.get(firstQuestionId);
            assertSoftly(softly -> {
                softly.assertThat(history.presentedAt()).isEqualTo(OLDER);
                softly.assertThat(history.accuracyScore()).isEqualTo(3);
            });
        }

        @ParameterizedTest
        @EnumSource(value = InterviewSessionStatus.class, names = {"IN_PROGRESS", "GRADING", "GRADING_FAILED"})
        void 채점되지_않은_세션의_문제는_점수가_null이다(InterviewSessionStatus status) {
            // given
            점수_없는_세션을_만든다(USER_ID, NEWER, status, List.of(firstQuestionId));

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            InterviewQuestionHistoryDto history = result.get(firstQuestionId);
            assertSoftly(softly -> {
                softly.assertThat(history.presentedAt()).isEqualTo(NEWER);
                softly.assertThat(history.accuracyScore()).isNull();
            });
        }

        @Test
        void 가장_최근_세션이_채점_중이면_이전_점수가_있어도_점수가_null이다() {
            // given
            채점된_세션을_만든다(USER_ID, OLDER, firstQuestionId, 3);
            점수_없는_세션을_만든다(USER_ID, NEWER, InterviewSessionStatus.GRADING, List.of(firstQuestionId));

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            InterviewQuestionHistoryDto history = result.get(firstQuestionId);
            assertSoftly(softly -> {
                softly.assertThat(history.presentedAt()).isEqualTo(NEWER);
                softly.assertThat(history.accuracyScore()).isNull();
            });
        }

        @Test
        void 무응답으로_채점된_문제는_점수가_0이다() {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    완료_세션(USER_ID, 1L, NEWER, SESSION_SCORE, SESSION_SCORE));
            InterviewAnswer answer = interviewAnswerRepository.save(
                    무응답_답안(session.getId(), firstQuestionId, 1, NEWER));
            interviewFeedbackRepository.save(무응답_피드백(answer.getId()));

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            assertThat(result.get(firstQuestionId).accuracyScore()).isZero();
        }

        @Test
        void 다른_사용자의_기록은_포함하지_않는다() {
            // given
            채점된_세션을_만든다(OTHER_USER_ID, NEWER, firstQuestionId, 3);

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            assertThat(result).isEmpty();
        }

        @Test
        void 요청한_문제의_기록만_조회한다() {
            // given
            점수_없는_세션을_만든다(USER_ID, NEWER, InterviewSessionStatus.GRADING,
                    List.of(firstQuestionId, secondQuestionId));

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of(firstQuestionId));

            // then
            assertThat(result).containsOnlyKeys(firstQuestionId);
        }

        @Test
        void 문제_목록이_비어있으면_빈_맵을_반환한다() {
            // given
            채점된_세션을_만든다(USER_ID, NEWER, firstQuestionId, 3);

            // when
            Map<Long, InterviewQuestionHistoryDto> result =
                    interviewAnswerQueryService.getQuestionIdToLatestHistory(USER_ID, List.of());

            // then
            assertThat(result).isEmpty();
        }
    }
}
