package gravit.code.social.dto.internal;

public record RecommendCandidateDto(
        long userId,
        String nickname,
        int profileImgNumber,
        int mutualFollowCount
) {
}
