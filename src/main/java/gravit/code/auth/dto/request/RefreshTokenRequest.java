package gravit.code.auth.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;

public record RefreshTokenRequest(

        @Schema(
                description = "리프레시 토큰",
                example = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.signature"
        )
        String refreshToken
) {
}
