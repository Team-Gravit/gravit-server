package gravit.code.fcm.dto.request;

import gravit.code.fcm.domain.Platform;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record RegisterFcmTokenRequest(
        @Schema(description = "클라이언트 디바이스 식별자(설치 단위 고유 ID)", example = "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        @NotBlank(message = "디바이스 아이디가 비어있습니다.")
        String deviceId,

        @Schema(description = "FCM 등록 토큰", example = "fGcT9...:APA91bH...")
        @NotBlank(message = "FCM 토큰이 비어있습니다.")
        String fcmToken,

        @Schema(description = "디바이스 플랫폼 (웹은 푸시 미지원, ANDROID 토큰에만 푸시 발송)", example = "ANDROID")
        @NotNull(message = "플랫폼이 비어있습니다.")
        Platform platform
) {
}
