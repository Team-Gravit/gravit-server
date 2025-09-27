package gravit.code.friend.dto;

public record FollowCountsResponse(
        long followerCount,
        long followingCount
) {
}
