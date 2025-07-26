package gravit.code.domain.user.dto.response;

public record MyPageResponse(
        String nickname,
        int profileImgNumber,
        String handle,
        long follower,
        long following
) {
}
