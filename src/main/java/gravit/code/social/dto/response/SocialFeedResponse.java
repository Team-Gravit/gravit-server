package gravit.code.social.dto.response;

import gravit.code.social.domain.FeedEventType;
import gravit.code.social.dto.internal.SocialFeedProjection;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;

public record SocialFeedResponse(
        Long feedId,
        Long actorId,
        String actorNickname,
        int actorProfileImgNumber,
        String actorHandle,
        String message,
        String timeAgo,
        boolean canCongratulate,
        LocalDateTime createdAt
) {
    public static SocialFeedResponse from(
            SocialFeedProjection projection,
            boolean canCongratulate
    ) {
        return new SocialFeedResponse(
                projection.id(),
                projection.actorId(),
                projection.actorNickname(),
                projection.actorProfileImgNumber(),
                projection.actorHandle(),
                generateMessage(projection.eventType(), projection.actorNickname(), projection.eventValue()),
                computeTimeAgo(projection.createdAt()),
                canCongratulate,
                projection.createdAt()
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

    private static String computeTimeAgo(LocalDateTime createdAt) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        long minutes = ChronoUnit.MINUTES.between(createdAt, now);

        if (minutes < 1) return "방금 전";
        if (minutes < 60) return minutes + "분 전";

        long hours = ChronoUnit.HOURS.between(createdAt, now);
        if (hours < 24) return hours + "시간 전";

        long days = ChronoUnit.DAYS.between(createdAt, now);
        return Math.min(days, 7) + "일 전";
    }
}
