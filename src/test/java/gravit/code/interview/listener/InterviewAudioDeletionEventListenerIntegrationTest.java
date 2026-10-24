package gravit.code.interview.listener;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interview.service.InterviewSessionCommandService;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import software.amazon.awssdk.services.s3.S3Client;

import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ALREADY_SUBMITTED;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

@TCSpringBootTest
class InterviewAudioDeletionEventListenerIntegrationTest {

    private static final long USER_ID = 1L;
    private static final String DELETION_QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";

    @Autowired
    private InterviewSessionCommandService interviewSessionCommandService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @MockitoBean
    private S3Client s3Client;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    private Map<String, String> 삭제_페이로드(long sessionId) {
        return Map.of(SESSION_ID_FIELD, String.valueOf(sessionId));
    }

    @Nested
    @DisplayName("면접 세션이 취소되면")
    class HandleSessionAbandoned {

        @Test
        void 커밋_후_음성_세션의_음성_삭제를_큐에_적재한다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when
            interviewSessionCommandService.abandon(USER_ID, session.getId());

            // then
            verify(retryEventPublisher).publish(DELETION_QUEUE_KEY, 삭제_페이로드(session.getId()));
            verifyNoInteractions(s3Client);
        }

        @Test
        void 텍스트_세션이면_적재하지_않는다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.TEXT));

            // when
            interviewSessionCommandService.abandon(USER_ID, session.getId());

            // then
            verifyNoInteractions(retryEventPublisher);
        }

        @Test
        void 취소가_실패해_롤백되면_적재하지_않는다() {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(USER_ID, InterviewSessionStatus.GRADING, InterviewInputType.VOICE));

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.abandon(USER_ID, session.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ALREADY_SUBMITTED);
            verifyNoInteractions(retryEventPublisher);
        }
    }
}
