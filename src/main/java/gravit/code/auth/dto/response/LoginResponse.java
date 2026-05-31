package gravit.code.auth.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import jakarta.validation.constraints.NotNull;

public record LoginResponse(

        @NotNull
        String accessToken,
        @NotNull
        String refreshToken,
        @JsonProperty("isOnboarded")
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