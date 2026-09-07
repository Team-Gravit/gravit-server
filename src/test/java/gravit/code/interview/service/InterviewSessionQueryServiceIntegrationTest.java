package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_GRADING;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
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
}
