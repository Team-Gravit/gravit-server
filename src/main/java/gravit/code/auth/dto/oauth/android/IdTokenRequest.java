package gravit.code.auth.dto.oauth.android;

import io.swagger.v3.oas.annotations.media.Schema;

public record IdTokenRequest(
        @Schema(
                description = "OAuth 제공자가 발급한 ID 토큰",
                example = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEifQ.payload.signature"
        )
        String idToken
) {
}
