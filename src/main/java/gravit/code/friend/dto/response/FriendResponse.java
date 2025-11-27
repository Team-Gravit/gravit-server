package gravit.code.friend.dto.response;

import gravit.code.friend.domain.Friend;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

@Builder
public record FriendResponse(

        @NotNull
        Long followeeId,
        @NotNull
        Long followerId
) {
    public static FriendResponse from(Friend friend) {
        return FriendResponse.builder()
                .followeeId(friend.getFolloweeId())
                .followerId(friend.getFollowerId())
                .build();
    }
}
