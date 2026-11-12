package gravit.code.interview.dto.internal;

import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewAudioUploadDto(

        String uploadUrl,

        LocalDateTime expiresAt
) {
    public static InterviewAudioUploadDto of(
            String uploadUrl,
            LocalDateTime expiresAt
    ) {
        return InterviewAudioUploadDto.builder()
                .uploadUrl(uploadUrl)
                .expiresAt(expiresAt)
                .build();
    }
}
