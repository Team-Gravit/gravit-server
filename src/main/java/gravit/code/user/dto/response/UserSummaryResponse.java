package gravit.code.user.dto.response;

public record UserSummaryResponse(
        long id,
        String nickname,
        int profileImgNumber
) {
}
