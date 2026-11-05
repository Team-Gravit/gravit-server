package gravit.code.auth.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.user.domain.Role;
import io.swagger.v3.oas.annotations.media.Schema;

public record WebLoginResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String accessToken,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        @JsonProperty("isOnboarded")
        boolean isOnboarded,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        Role role
) {
    public static WebLoginResponse from(LoginResponse loginResponse) {
        return new WebLoginResponse(
                loginResponse.accessToken(),
                loginResponse.isOnboarded(),
                loginResponse.role()
        );
    }
}
