package gravit.code.auth.dto.response;

import gravit.code.auth.domain.AccessToken;

public record ReissueResponse(
        String accessToken
) {
    public static ReissueResponse from(AccessToken accessToken) {
        return new ReissueResponse(accessToken.token());
    }
}
