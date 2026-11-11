package gravit.code.social.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record RecommendUserResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long userId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int mutualFollowCount,

        @Schema(
                description = "함께 아는 친구 중 내가 가장 최근에 팔로우한 사람의 닉네임. 탈퇴한 사람은 빠지며, 함께 아는 친구가 없거나 모두 탈퇴 처리 중이면 null",
                example = "그래빗",
                nullable = true,
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String mutualFollowPreviewNickname
) {
    public static RecommendUserResponse of(
            long userId,
            String nickname,
            int profileImgNumber,
            int mutualFollowCount,
            String mutualFollowPreviewNickname
    ) {
        return RecommendUserResponse.builder()
                .userId(userId)
                .nickname(nickname)
                .profileImgNumber(profileImgNumber)
                .mutualFollowCount(mutualFollowCount)
                .mutualFollowPreviewNickname(mutualFollowPreviewNickname)
                .build();
    }
}
