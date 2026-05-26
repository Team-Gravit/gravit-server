package gravit.code.social.dto.response;

import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record RecommendUserResponse(
        long userId,
        String nickname,
        int profileImgNumber,
        int mutualFollowCount
) {
    public static RecommendUserResponse of(
            long userId,
            String nickname,
            int profileImgNumber,
            int mutualFollowCount
    ) {
        return RecommendUserResponse.builder()
                .userId(userId)
                .nickname(nickname)
                .profileImgNumber(profileImgNumber)
                .mutualFollowCount(mutualFollowCount)
                .build();
    }
}
