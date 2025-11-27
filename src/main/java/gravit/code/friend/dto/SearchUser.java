package gravit.code.friend.dto;

public record SearchUser(

        long userId,
        int profileImgNumber,
        String nickname,
        String handle,
        boolean isFollowing
) {
}
