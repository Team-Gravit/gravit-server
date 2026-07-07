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
                description = "알림 헤드라인 메시지",
                example = "홍길동님이 나를 팔로우했어요! 👀",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String message,

        @Schema(
                description = "알림 서브텍스트 (헤드라인 하위 보조 문구, 없으면 null)",
                example = "오늘 학습하면 계속 이어갈 수 있어요"
        )
        String subText,

        @Schema(
                description = "액션 버튼 타입 (NONE/FOLLOW_BACK/CONGRATULATE/GO_TO_LEARNING/GO_TO_NOTICE/GO_TO_INQUIRY)",
                example = "FOLLOW_BACK",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String actionType,

        @Schema(description = "액션 대상 ID — actionType에 따라 의미가 다름 (없으면 null)")
        Long targetId,

        @Schema(description = "축하 완료 여부 (FRIEND_ACTIVITY 알림에서만 값이 있으며, 그 외 알림은 null). true면 소셜 피드와 동일하게 '축하 완료' 상태로 노출한다")
        Boolean congratulated,

        @Schema(description = "읽음 여부", requiredMode = Schema.RequiredMode.REQUIRED)
        boolean read,

        @Schema(description = "생성 시각", requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime createdAt,

        @Schema(
                description = "생성 시각의 상대 표현 (N분 전 / N시간 전 / 어제 / N일 전 / N주 전)",
                example = "3시간 전",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String timeAgo,

        @Schema(description = "팔로우 알림의 상대 유저 정보 (FOLLOW 알림이 아니거나 탈퇴한 유저면 null)")
        NotificationActor actor

) {
    public static NotificationResponse of(
            Notification notification,
            NotificationActionType resolvedActionType,
            NotificationActor actor,
            Boolean congratulated,
            String timeAgo
    ) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .type(notification.getType().name())
                .message(notification.getMessage())
                .subText(notification.getSubText())
                .actionType(resolvedActionType.name())
                .targetId(notification.getTargetId())
                .congratulated(congratulated)
                .read(notification.isRead())
                .createdAt(notification.getCreatedAt())
                .timeAgo(timeAgo)
                .actor(actor)
                .build();
    }
}
