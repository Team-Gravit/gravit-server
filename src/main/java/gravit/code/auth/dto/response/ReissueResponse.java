package gravit.code.auth.dto.response;

import gravit.code.auth.domain.AccessToken;
import jakarta.validation.constraints.NotNull;

public record ReissueResponse(

        @NotNull
        String accessToken
) {
    public static ReissueResponse from(AccessToken accessToken) {
        return new ReissueResponse(accessToken.token());
    }
}
