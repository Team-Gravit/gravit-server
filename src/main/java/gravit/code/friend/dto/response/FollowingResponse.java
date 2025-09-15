package gravit.code.friend.dto.response;


public record FollowingResponse(
        Long id,
        String nickname,
        int profileImgNumber,
        String handle
){
}
