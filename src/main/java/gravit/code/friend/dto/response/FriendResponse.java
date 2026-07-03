package gravit.code.friend.dto.response;

import gravit.code.friend.domain.Friend;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record FriendResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        Long followeeId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        Long followerId
) {
    public static FriendResponse from(Friend friend) {
        return FriendResponse.builder()
                .followeeId(friend.getFolloweeId())
                .followerId(friend.getFollowerId())
                .build();
    }
}
