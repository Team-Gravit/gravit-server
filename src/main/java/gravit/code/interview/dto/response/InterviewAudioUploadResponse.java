package gravit.code.interview.dto.response;

import gravit.code.interview.dto.internal.InterviewAudioUploadDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewAudioUploadResponse(

        @Schema(
                description = "음성 키. 업로드를 마친 뒤 답안 제출 본문에 그대로 담습니다.",
                example = "interview/12/1.m4a",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String audioKey,

        @Schema(
                description = "업로드 URL. 이 URL로 PUT 요청을 보내 음성 원본을 올립니다.",
                example = "https://gravit-interview-audio.s3.ap-northeast-2.amazonaws.com/interview/12/1.m4a?X-Amz-Algorithm=...",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String uploadUrl,

        @Schema(
                description = "업로드 URL 만료 시각",
                example = "2026-09-08T14:30:00",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        LocalDateTime expiresAt
) {
    public static InterviewAudioUploadResponse of(
            String audioKey,
            InterviewAudioUploadDto upload
    ) {
        return InterviewAudioUploadResponse.builder()
                .audioKey(audioKey)
                .uploadUrl(upload.uploadUrl())
                .expiresAt(upload.expiresAt())
                .build();
    }
}
