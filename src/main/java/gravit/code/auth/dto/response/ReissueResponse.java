package gravit.code.auth.dto.response;

import gravit.code.auth.domain.AccessToken;
import io.swagger.v3.oas.annotations.media.Schema;

public record ReissueResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String accessToken
) {
    public static ReissueResponse from(AccessToken accessToken) {
        return new ReissueResponse(accessToken.token());
    }
}
