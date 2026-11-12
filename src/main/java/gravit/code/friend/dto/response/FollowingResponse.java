package gravit.code.friend.dto.response;


import io.swagger.v3.oas.annotations.media.Schema;

public record FollowingResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long id,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String handle
){
}
