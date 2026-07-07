package gravit.code.social.dto.response;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.dto.internal.SocialFeedProjection;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

public record SocialFeedResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        Long feedId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        Long actorId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String actorNickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int actorProfileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String actorHandle,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String message,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String timeAgo,

        @Schema(
                description = "이 피드를 이미 축하했는지 여부. true면 '축하 완료' 상태로 노출한다",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean congratulated,

        @Schema(
                description = "지금 축하 가능한지 여부. congratulated=true(완료)이거나 해당 유저 대상 하루 3회 소진 시 false",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean canCongratulate,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime createdAt
) {
    public static SocialFeedResponse of(
            SocialFeedProjection projection,
            boolean congratulated,
            boolean canCongratulate,
            String timeAgo
    ) {
        return new SocialFeedResponse(
                projection.id(),
                projection.actorId(),
                projection.actorNickname(),
                projection.actorProfileImgNumber(),
                projection.actorHandle(),
                generateMessage(projection.eventType(), projection.eventValue()),
                timeAgo,
                congratulated,
                canCongratulate,
                projection.createdAt()
        );
    }

    private static String generateMessage(
            FeedEventType eventType,
            String eventValue
    ) {
        return switch (eventType) {
            case PLANET_COMPLETE -> eventValue + " 행성을 정복했어요!";
            case STREAK_DAYS -> eventValue + "일 연속 학습을 달성했어요!";
            case TIER_PROMOTION -> eventValue + "로 승급했어요!";
            case LEVEL_UP -> "LV." + eventValue + "로 레벨업했어요!";
        };
    }
}
