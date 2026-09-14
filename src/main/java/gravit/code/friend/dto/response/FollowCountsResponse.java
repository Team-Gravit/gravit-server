package gravit.code.friend.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record FollowCountsResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long followerCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long followingCount
) {
    public static FollowCountsResponse of(
            long followerCount,
            long followingCount
    ) {
        return FollowCountsResponse.builder()
                .followerCount(followerCount)
                .followingCount(followingCount)
                .build();
    }
}
