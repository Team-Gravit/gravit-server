package gravit.code.interview.infrastructure;

import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ObjectIdentifier;
import software.amazon.awssdk.services.s3.model.S3Exception;

import java.util.Map;

import static gravit.code.interview.fixture.InterviewAudioS3Fixture.권한_거부;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.삭제_성공;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.세션_접두사;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_목록;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_키;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class InterviewAudioDeletionRetryTargetIntegrationTest {

    private static final long SESSION_ID = 10L;
    private static final String RETRY_QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";

    @Autowired
    private InterviewAudioDeletionRetryTarget interviewAudioDeletionRetryTarget;

    @MockitoBean
    private S3Client s3Client;

    private Map<String, String> 재시도_페이로드(long sessionId) {
        return Map.of(SESSION_ID_FIELD, String.valueOf(sessionId));
    }

    @Nested
    @DisplayName("재시도 큐 항목을 재처리할 때")
    class Reprocess {

        @Test
        void 큐_키는_서비스가_적재하는_키와_같다() {
            // when
            String queueKey = interviewAudioDeletionRetryTarget.queueKey();

            // then
            assertThat(queueKey).isEqualTo(RETRY_QUEUE_KEY);
        }

        @Test
        void 서비스가_적재한_페이로드로_세션의_음성을_지운다() {
            // given
            String key = 음성_키(SESSION_ID, 1);
            doReturn(음성_목록(key)).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));
            doReturn(삭제_성공()).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            // when
            interviewAudioDeletionRetryTarget.reprocess(재시도_페이로드(SESSION_ID));

            // then
            ArgumentCaptor<ListObjectsV2Request> listCaptor = ArgumentCaptor.forClass(ListObjectsV2Request.class);
            ArgumentCaptor<DeleteObjectsRequest> deleteCaptor = ArgumentCaptor.forClass(DeleteObjectsRequest.class);
            verify(s3Client).listObjectsV2(listCaptor.capture());
            verify(s3Client).deleteObjects(deleteCaptor.capture());

            assertSoftly(softly -> {
                softly.assertThat(listCaptor.getValue().prefix()).isEqualTo(세션_접두사(SESSION_ID));
                softly.assertThat(deleteCaptor.getValue().delete().objects())
                        .extracting(ObjectIdentifier::key)
                        .containsExactly(key);
            });
        }

        @Test
        void 삭제가_실패하면_예외를_다시_던져_재적재되게_한다() {
            // given
            doThrow(권한_거부()).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));

            // when & then
            assertThatThrownBy(() -> interviewAudioDeletionRetryTarget.reprocess(재시도_페이로드(SESSION_ID)))
                    .isInstanceOf(S3Exception.class);
        }
    }
}
