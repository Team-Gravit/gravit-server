package gravit.code.interview.infrastructure;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.dto.internal.InterviewAudioUploadDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.Delete;
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectsResponse;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ObjectIdentifier;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_DELETE_FAILED;

@Slf4j
@Component
public class InterviewAudioStorage {

    private static final String DELETE_ERROR_FORMAT = "%s(%s)";

    private final S3Presigner s3Presigner;
    private final S3Client s3Client;
    private final Clock clock;
    private final String bucket;
    private final Duration uploadExpiry;

    public InterviewAudioStorage(
            S3Presigner s3Presigner,
            S3Client s3Client,
            Clock clock,
            @Value("${aws.s3.bucket}") String bucket,
            @Value("${aws.s3.upload-expiry}") Duration uploadExpiry
    ) {
        this.s3Presigner = s3Presigner;
        this.s3Client = s3Client;
        this.clock = clock;
        this.bucket = bucket;
        this.uploadExpiry = uploadExpiry;
    }

    public InterviewAudioUploadDto presignUpload(
            String audioKey,
            String contentType
    ) {
        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                .bucket(bucket)
                .key(audioKey)
                .contentType(contentType)
                .build();

        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(uploadExpiry)
                .putObjectRequest(putObjectRequest)
                .build();

        PresignedPutObjectRequest presignedRequest = s3Presigner.presignPutObject(presignRequest);

        return InterviewAudioUploadDto.of(
                presignedRequest.url().toString(),
                LocalDateTime.now(clock).plus(uploadExpiry)
        );
    }

    public void deleteAllByPrefix(String prefix) {
        ListObjectsV2Request listRequest = ListObjectsV2Request.builder()
                .bucket(bucket)
                .prefix(prefix)
                .build();

        List<ObjectIdentifier> objects = s3Client.listObjectsV2(listRequest).contents().stream()
                .map(object -> ObjectIdentifier.builder().key(object.key()).build())
                .toList();

        if (objects.isEmpty()) {
            return;
        }

        DeleteObjectsRequest deleteRequest = DeleteObjectsRequest.builder()
                .bucket(bucket)
                .delete(Delete.builder()
                        .objects(objects)
                        .quiet(true)
                        .build())
                .build();

        DeleteObjectsResponse response = s3Client.deleteObjects(deleteRequest);

        if (!response.errors().isEmpty()) {
            List<String> failures = response.errors().stream()
                    .map(error -> String.format(DELETE_ERROR_FORMAT, error.key(), error.code()))
                    .toList();

            log.warn("면접 음성 삭제 일부 실패: prefix={}, errors={}", prefix, failures);
            throw new RestApiException(INTERVIEW_AUDIO_DELETE_FAILED);
        }
    }
}
