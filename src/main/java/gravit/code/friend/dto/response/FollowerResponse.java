package gravit.code.friend.dto.response;

public record FollowerResponse(
        Long id,
        String nickname,
        int profileImgNumber,
        String handle
) {}
