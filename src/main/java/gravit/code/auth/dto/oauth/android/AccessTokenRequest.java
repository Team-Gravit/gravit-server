package gravit.code.auth.dto.oauth.android;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

public record AccessTokenRequest(

        @Schema(description = "제공자가 발급한 액세스 토큰")
        @NotNull(message = "액세스 토큰이 비어있습니다.")
        String accessToken
) {
}
