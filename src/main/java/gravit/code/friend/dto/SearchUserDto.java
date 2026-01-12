package gravit.code.friend.dto;

public record SearchUserDto(
        long userId,
        int profileImgNumber,
        String nickname,
        String handle,
        boolean isFollowing
) {
}
