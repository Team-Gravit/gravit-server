package gravit.code.domain.friend.dto;

public record SearchUser(
        Long userId,
        int profileImgNumber,
        String nickname,
        String handle,
        boolean isFollowing
) {
}
