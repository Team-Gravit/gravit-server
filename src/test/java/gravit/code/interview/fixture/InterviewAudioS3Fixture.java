package gravit.code.interview.fixture;

import software.amazon.awssdk.services.s3.model.DeleteObjectsResponse;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Response;
import software.amazon.awssdk.services.s3.model.S3Error;
import software.amazon.awssdk.services.s3.model.S3Exception;
import software.amazon.awssdk.services.s3.model.S3Object;

import java.util.Arrays;

import static org.mockito.ArgumentMatchers.argThat;

public class InterviewAudioS3Fixture {

    private static final String SESSION_PREFIX_FORMAT = "interview/%d/";
    private static final String AUDIO_KEY_FORMAT = "interview/%d/%d.m4a";
    private static final String ACCESS_DENIED_CODE = "AccessDenied";
    private static final String ACCESS_DENIED_MESSAGE = "Access Denied";
    private static final int FORBIDDEN_STATUS = 403;

    public static String 세션_접두사(long sessionId) {
        return String.format(SESSION_PREFIX_FORMAT, sessionId);
    }

    public static String 음성_키(
            long sessionId,
            int displayOrder
    ) {
        return String.format(AUDIO_KEY_FORMAT, sessionId, displayOrder);
    }

    public static ListObjectsV2Request 세션_목록_요청(long sessionId) {
        String prefix = 세션_접두사(sessionId);
        return argThat(request -> request != null && prefix.equals(request.prefix()));
    }

    public static ListObjectsV2Response 음성_목록(String... keys) {
        return ListObjectsV2Response.builder()
                .contents(Arrays.stream(keys)
                        .map(key -> S3Object.builder().key(key).build())
                        .toList())
                .build();
    }

    public static DeleteObjectsResponse 삭제_성공() {
        return DeleteObjectsResponse.builder().build();
    }

    public static DeleteObjectsResponse 일부_삭제_실패(String key) {
        return DeleteObjectsResponse.builder()
                .errors(S3Error.builder()
                        .key(key)
                        .code(ACCESS_DENIED_CODE)
                        .message(ACCESS_DENIED_MESSAGE)
                        .build())
                .build();
    }

    public static S3Exception 권한_거부() {
        return (S3Exception) S3Exception.builder()
                .statusCode(FORBIDDEN_STATUS)
                .message(ACCESS_DENIED_MESSAGE)
                .build();
    }
}
