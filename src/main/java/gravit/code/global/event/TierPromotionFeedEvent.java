package gravit.code.global.event;

public record TierPromotionFeedEvent(
        long userId,
        String tierName
) {
}
