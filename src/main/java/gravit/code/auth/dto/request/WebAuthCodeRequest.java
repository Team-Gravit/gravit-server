package gravit.code.auth.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

public record WebAuthCodeRequest(

        @Schema(
                description = "OAuth 제공자가 발급한 인가 코드",
                example = "4/0AVMBsJh-authorization-code",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull(message = "인증 코드가 비어있습니다.")
        String code,

        @Schema(
                description = "로그인 URL 조회 때 서버가 발급한 state. OAuth 콜백 쿼리로 돌아온 값을 그대로 보낸다",
                example = "3f1c2b8e-7a4d-4e8a-9b1f-0c2d3e4f5a6b",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull(message = "state가 비어있습니다.")
        String state
) {
}
