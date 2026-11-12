package gravit.code.friend.dto.event;

public record FollowedEvent(
        long followerId,

        long followeeId
) {
}
