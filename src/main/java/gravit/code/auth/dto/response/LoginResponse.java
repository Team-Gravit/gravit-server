package gravit.code.auth.dto.response;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;

public record LoginResponse(
        String accessToken,
        String refreshToken,
        boolean isOnboarded
) {
    public static LoginResponse of(
            AccessToken accessToken,
            RefreshToken refreshToken,
            boolean isOnboarded
    ) {
        return new LoginResponse(accessToken.token(), refreshToken.token(), isOnboarded);
    }
}