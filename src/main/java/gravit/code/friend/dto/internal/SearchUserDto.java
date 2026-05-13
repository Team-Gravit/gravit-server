package gravit.code.friend.dto.internal;

public record SearchUserDto(
        long userId,
        int profileImgNumber,
        String nickname,
        String handle,
        boolean isFollowing
) {
}
