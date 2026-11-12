package gravit.code.auth.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.user.domain.Role;
import io.swagger.v3.oas.annotations.media.Schema;

public record LoginResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String accessToken,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String refreshToken,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        @JsonProperty("isOnboarded")
        boolean isOnboarded,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        Role role
) {
    public static LoginResponse of(
            AccessToken accessToken,
            RefreshToken refreshToken,
            boolean isOnboarded,
            Role role
    ) {
        return new LoginResponse(accessToken.token(), refreshToken.token(), isOnboarded, role);
    }
}
