package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.dto.response.InterviewSessionQuestionResponse;
import gravit.code.interview.dto.response.InterviewSessionQuestionsResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_GRADING;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interviewQuestion.fixture.InterviewQuestionFixture.문제;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewSessionQueryServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long UNKNOWN_SESSION_ID = 999L;

    @Autowired
    private InterviewSessionQueryService interviewSessionQueryService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Nested
    @DisplayName("세션 상태를 조회할 때")
    class GetStatus {

        @ParameterizedTest
        @EnumSource(InterviewSessionStatus.class)
        void 모든_상태에서_세션_상태를_돌려준다(InterviewSessionStatus status) {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, status));

            // when
            InterviewSessionStatusResponse response = interviewSessionQueryService.getStatus(USER_ID, session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.sessionId()).isEqualTo(session.getId());
                softly.assertThat(response.status()).isEqualTo(status);
            });
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewSessionQueryService.getStatus(USER_ID, UNKNOWN_SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 남의_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.GRADING));

            // when & then
            assertThatThrownBy(() -> interviewSessionQueryService.getStatus(OTHER_USER_ID, session.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }
    }

    @Nested
    @DisplayName("채점 대상 세션을 조회할 때")
    class GetGradingSession {

        @Test
        void 채점_중인_세션을_돌려준다() {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.GRADING));

            // when
            InterviewSession found = interviewSessionQueryService.getGradingSession(session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(found.getId()).isEqualTo(session.getId());
                softly.assertThat(found.getStatus()).isEqualTo(InterviewSessionStatus.GRADING);
            });
        }

        @ParameterizedTest
        @EnumSource(value = InterviewSessionStatus.class, names = {"IN_PROGRESS", "GRADING_FAILED", "COMPLETED", "ABANDONED"})
        void 채점_중이_아니면_예외를_던진다(InterviewSessionStatus status) {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, status));

            // when & then
            assertThatThrownBy(() -> interviewSessionQueryService.getGradingSession(session.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_GRADING);
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewSessionQueryService.getGradingSession(UNKNOWN_SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("문제 목록을 조회할 때")
    class GetQuestions {

        private static final int QUESTION_COUNT = 5;
        private static final int FIRST_DISPLAY_ORDER = 1;

        private List<InterviewQuestion> 출제한다(long sessionId) {
            List<InterviewTopic> topics = List.of(
                    InterviewTopic.DATA_STRUCTURE,
                    InterviewTopic.ALGORITHM,
                    InterviewTopic.DATABASE,
                    InterviewTopic.OPERATING_SYSTEM,
                    InterviewTopic.NETWORK
            );

            List<InterviewQuestion> questions = new ArrayList<>();
            List<InterviewAnswer> answers = new ArrayList<>();
            for (int index = 0; index < topics.size(); index++) {
                InterviewQuestion question = interviewQuestionRepository.save(
                        문제(topics.get(index), InterviewDifficulty.NORMAL));
                questions.add(question);
                answers.add(InterviewAnswer.create(sessionId, question.getId(), index + FIRST_DISPLAY_ORDER));
            }
            interviewAnswerRepository.saveAll(answers);

            return questions;
        }

        @Test
        void 문항_번호_오름차순으로_본문을_돌려준다() {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(USER_ID, InterviewSessionStatus.IN_PROGRESS));
            List<InterviewQuestion> questions = 출제한다(session.getId());

            // when
            InterviewSessionQuestionsResponse response =
                    interviewSessionQueryService.getQuestions(USER_ID, session.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.sessionId()).isEqualTo(session.getId());
                softly.assertThat(response.questions()).hasSize(QUESTION_COUNT);
                softly.assertThat(response.questions().stream().map(InterviewSessionQuestionResponse::displayOrder))
                        .containsExactly(1, 2, 3, 4, 5);
                softly.assertThat(response.questions().stream().map(InterviewSessionQuestionResponse::content))
                        .containsExactlyElementsOf(questions.stream().map(InterviewQuestion::getContent).toList());
            });
        }

        @ParameterizedTest
        @EnumSource(InterviewSessionStatus.class)
        void 모든_상태에서_조회할_수_있다(InterviewSessionStatus status) {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, status));
            출제한다(session.getId());

            // when
            InterviewSessionQuestionsResponse response =
                    interviewSessionQueryService.getQuestions(USER_ID, session.getId());

            // then
            assertThat(response.questions()).hasSize(QUESTION_COUNT);
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewSessionQueryService.getQuestions(USER_ID, UNKNOWN_SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 남의_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(USER_ID, InterviewSessionStatus.IN_PROGRESS));
            출제한다(session.getId());

            // when & then
            assertThatThrownBy(() -> interviewSessionQueryService.getQuestions(OTHER_USER_ID, session.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }
    }

}
