package gravit.code.interview.infrastructure;

import gravit.code.interview.dto.internal.InterviewAudioUploadDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;

@Component
public class InterviewAudioStorage {

    private final S3Presigner s3Presigner;
    private final Clock clock;

    private final String bucket;
    private final Duration uploadExpiry;

    public InterviewAudioStorage(
            S3Presigner s3Presigner,
            Clock clock,
            @Value("${aws.s3.bucket}") String bucket,
            @Value("${aws.s3.upload-expiry}") Duration uploadExpiry
    ) {
        this.s3Presigner = s3Presigner;
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
}
