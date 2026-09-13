package gravit.code.interview.service;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ObjectIdentifier;
import software.amazon.awssdk.services.s3.model.S3Exception;

import java.util.List;
import java.util.Map;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_DELETE_FAILED;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.권한_거부;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.삭제_성공;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.세션_목록_요청;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.세션_접두사;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_목록;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_키;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.일부_삭제_실패;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

@TCSpringBootTest
class InterviewAudioDeletionServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long SESSION_ID = 10L;
    private static final long OTHER_SESSION_ID = 20L;
    private static final String BUCKET = "test-interview-audio";
    private static final String RETRY_QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";
    private static final String PUBLISH_ERROR_MESSAGE = "Redis 연결 실패";

    @Autowired
    private InterviewAudioDeletionService interviewAudioDeletionService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @MockitoBean
    private S3Client s3Client;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    private Map<String, String> 재시도_페이로드(long sessionId) {
        return Map.of(SESSION_ID_FIELD, String.valueOf(sessionId));
    }

    @Nested
    @DisplayName("음성 세션 id를 조회할 때")
    class GetVoiceSessionIds {

        @Test
        void 음성_세션만_돌려준다() {
            // given
            InterviewSession voiceSession = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));
            interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.TEXT));

            // when
            List<Long> sessionIds = interviewAudioDeletionService.getVoiceSessionIds(USER_ID);

            // then
            assertThat(sessionIds).containsExactly(voiceSession.getId());
        }

        @ParameterizedTest
        @EnumSource(InterviewSessionStatus.class)
        void 세션_상태와_관계없이_음성_세션을_돌려준다(InterviewSessionStatus status) {
            // given
            InterviewSession voiceSession = interviewSessionRepository.save(
                    상태_세션(USER_ID, status, InterviewInputType.VOICE));

            // when
            List<Long> sessionIds = interviewAudioDeletionService.getVoiceSessionIds(USER_ID);

            // then
            assertThat(sessionIds).containsExactly(voiceSession.getId());
        }

        @Test
        void 다른_회원의_세션은_돌려주지_않는다() {
            // given
            interviewSessionRepository.save(진행중_세션(OTHER_USER_ID, InterviewInputType.VOICE));

            // when
            List<Long> sessionIds = interviewAudioDeletionService.getVoiceSessionIds(USER_ID);

            // then
            assertThat(sessionIds).isEmpty();
        }

        @Test
        void 세션이_없으면_빈_목록을_돌려준다() {
            // when
            List<Long> sessionIds = interviewAudioDeletionService.getVoiceSessionIds(USER_ID);

            // then
            assertThat(sessionIds).isEmpty();
        }
    }

    @Nested
    @DisplayName("세션 하나의 음성을 지울 때")
    class DeleteBySessionId {

        @Test
        void 세션_접두사로_조회한_키를_한_번에_지운다() {
            // given
            String firstKey = 음성_키(SESSION_ID, 1);
            String secondKey = 음성_키(SESSION_ID, 2);
            doReturn(음성_목록(firstKey, secondKey)).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));
            doReturn(삭제_성공()).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            // when
            interviewAudioDeletionService.deleteBySessionId(SESSION_ID);

            // then
            ArgumentCaptor<ListObjectsV2Request> listCaptor = ArgumentCaptor.forClass(ListObjectsV2Request.class);
            ArgumentCaptor<DeleteObjectsRequest> deleteCaptor = ArgumentCaptor.forClass(DeleteObjectsRequest.class);
            verify(s3Client).listObjectsV2(listCaptor.capture());
            verify(s3Client).deleteObjects(deleteCaptor.capture());

            assertSoftly(softly -> {
                softly.assertThat(listCaptor.getValue().bucket()).isEqualTo(BUCKET);
                softly.assertThat(listCaptor.getValue().prefix()).isEqualTo(세션_접두사(SESSION_ID));
                softly.assertThat(deleteCaptor.getValue().bucket()).isEqualTo(BUCKET);
                softly.assertThat(deleteCaptor.getValue().delete().objects())
                        .extracting(ObjectIdentifier::key)
                        .containsExactly(firstKey, secondKey);
                softly.assertThat(deleteCaptor.getValue().delete().quiet()).isTrue();
            });
        }

        @Test
        void 조회한_키가_없으면_삭제를_요청하지_않는다() {
            // given
            doReturn(음성_목록()).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));

            // when
            interviewAudioDeletionService.deleteBySessionId(SESSION_ID);

            // then
            verify(s3Client, never()).deleteObjects(any(DeleteObjectsRequest.class));
        }

        @Test
        void 삭제_응답에_실패한_키가_있으면_예외를_던진다() {
            // given
            String key = 음성_키(SESSION_ID, 1);
            doReturn(음성_목록(key)).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));
            doReturn(일부_삭제_실패(key)).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            // when & then
            assertThatThrownBy(() -> interviewAudioDeletionService.deleteBySessionId(SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_DELETE_FAILED);
        }

        @Test
        void 목록_조회가_실패하면_S3_예외를_그대로_던진다() {
            // given
            doThrow(권한_거부()).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));

            // when & then
            assertThatThrownBy(() -> interviewAudioDeletionService.deleteBySessionId(SESSION_ID))
                    .isInstanceOf(S3Exception.class);
        }
    }

    @Nested
    @DisplayName("여러 세션의 음성을 지울 때")
    class DeleteAllBySessionIds {

        @Test
        void 모두_지우면_재시도_큐에_적재하지_않는다() {
            // given
            doReturn(음성_목록(음성_키(SESSION_ID, 1))).when(s3Client).listObjectsV2(세션_목록_요청(SESSION_ID));
            doReturn(음성_목록(음성_키(OTHER_SESSION_ID, 1))).when(s3Client).listObjectsV2(세션_목록_요청(OTHER_SESSION_ID));
            doReturn(삭제_성공()).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            // when
            interviewAudioDeletionService.deleteAllBySessionIds(List.of(SESSION_ID, OTHER_SESSION_ID));

            // then
            verify(s3Client, times(2)).deleteObjects(any(DeleteObjectsRequest.class));
            verifyNoInteractions(retryEventPublisher);
        }

        @Test
        void 실패한_세션만_재시도_큐에_적재하고_나머지_세션은_계속_지운다() {
            // given
            doThrow(권한_거부()).when(s3Client).listObjectsV2(세션_목록_요청(SESSION_ID));
            doReturn(음성_목록(음성_키(OTHER_SESSION_ID, 1))).when(s3Client).listObjectsV2(세션_목록_요청(OTHER_SESSION_ID));
            doReturn(삭제_성공()).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            // when
            interviewAudioDeletionService.deleteAllBySessionIds(List.of(SESSION_ID, OTHER_SESSION_ID));

            // then
            verify(retryEventPublisher).publish(RETRY_QUEUE_KEY, 재시도_페이로드(SESSION_ID));
            verify(retryEventPublisher, never()).publish(RETRY_QUEUE_KEY, 재시도_페이로드(OTHER_SESSION_ID));
            verify(s3Client).deleteObjects(any(DeleteObjectsRequest.class));
        }

        @Test
        void 삭제_응답에_실패한_키가_있어도_재시도_큐에_적재한다() {
            // given
            String key = 음성_키(SESSION_ID, 1);
            doReturn(음성_목록(key)).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));
            doReturn(일부_삭제_실패(key)).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            // when
            interviewAudioDeletionService.deleteAllBySessionIds(List.of(SESSION_ID));

            // then
            verify(retryEventPublisher).publish(RETRY_QUEUE_KEY, 재시도_페이로드(SESSION_ID));
        }

        @Test
        void 적재가_실패해도_예외_없이_다음_세션을_지운다() {
            // given
            doThrow(권한_거부()).when(s3Client).listObjectsV2(세션_목록_요청(SESSION_ID));
            doReturn(음성_목록(음성_키(OTHER_SESSION_ID, 1))).when(s3Client).listObjectsV2(세션_목록_요청(OTHER_SESSION_ID));
            doReturn(삭제_성공()).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));
            doThrow(new RuntimeException(PUBLISH_ERROR_MESSAGE)).when(retryEventPublisher).publish(anyString(), anyMap());

            // when & then
            assertThatCode(() -> interviewAudioDeletionService.deleteAllBySessionIds(List.of(SESSION_ID, OTHER_SESSION_ID)))
                    .doesNotThrowAnyException();
            verify(s3Client).deleteObjects(any(DeleteObjectsRequest.class));
        }

        @Test
        void 세션이_없으면_S3를_호출하지_않는다() {
            // when
            interviewAudioDeletionService.deleteAllBySessionIds(List.of());

            // then
            verifyNoInteractions(s3Client, retryEventPublisher);
        }
    }
}
