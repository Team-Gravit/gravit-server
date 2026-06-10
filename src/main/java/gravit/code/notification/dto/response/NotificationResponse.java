package gravit.code.notification.dto.response;

import gravit.code.notification.domain.Notification;
import gravit.code.notification.domain.NotificationActionType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record NotificationResponse(

        @Schema(description = "알림 ID", requiredMode = Schema.RequiredMode.REQUIRED)
        Long id,

        @Schema(
                description = "알림 타입",
                example = "FOLLOW",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String type,

        @Schema(
                description = "알림 메시지",
                example = "홍길동님이 나를 팔로우했어요! 👀",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String message,

        @Schema(
                description = "액션 버튼 타입 (NONE/FOLLOW_BACK/UNFOLLOW/CONGRATULATE/GO_TO_LEARNING/GO_TO_NOTICE)",
                example = "FOLLOW_BACK",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String actionType,

        @Schema(description = "액션 대상 ID — actionType에 따라 의미가 다름 (없으면 null)")
        Long targetId,

        @Schema(description = "읽음 여부", requiredMode = Schema.RequiredMode.REQUIRED)
        boolean read,

        @Schema(description = "생성 시각", requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime createdAt

) {
    public static NotificationResponse of(
            Notification notification,
            NotificationActionType resolvedActionType
    ) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .type(notification.getType().name())
                .message(notification.getMessage())
                .actionType(resolvedActionType.name())
                .targetId(notification.getTargetId())
                .read(notification.isRead())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
