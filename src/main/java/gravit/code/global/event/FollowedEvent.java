package gravit.code.global.event;

public record FollowedEvent(
        long followerId,
        long followeeId
) {
}
