package gravit.code.social.dto.response;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.dto.internal.SocialFeedProjection;

import java.time.LocalDateTime;

public record SocialFeedResponse(
        Long feedId,
        Long actorId,
        String actorNickname,
        int actorProfileImgNumber,
        String actorHandle,
        String message,
        LocalDateTime createdAt,
        LocalDateTime congratulatedAt
) {
    public static SocialFeedResponse from(SocialFeedProjection projection) {
        return new SocialFeedResponse(
                projection.id(),
                projection.actorId(),
                projection.actorNickname(),
                projection.actorProfileImgNumber(),
                projection.actorHandle(),
                generateMessage(projection.eventType(), projection.actorNickname(), projection.eventValue()),
                projection.createdAt(),
                projection.congratulatedAt()
        );
    }

    private static String generateMessage(
            FeedEventType eventType,
            String nickname,
            String eventValue
    ) {
        return switch (eventType) {
            case PLANET_COMPLETE -> nickname + "님이 " + eventValue + " 행성을 정복했어요!";
            case STREAK_DAYS -> nickname + "님이 " + eventValue + "일 연속 학습을 달성했어요!";
            case TIER_PROMOTION -> nickname + "님이 " + eventValue + "로 승급했어요!";
            case LEVEL_UP -> nickname + "님이 LV." + eventValue + "로 레벨업했어요!";
        };
    }
}
