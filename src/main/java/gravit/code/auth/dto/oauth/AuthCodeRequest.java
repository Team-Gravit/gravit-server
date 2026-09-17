package gravit.code.auth.dto.oauth;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

public record AuthCodeRequest(

        @Schema(
                description = "OAuth 제공자가 발급한 인가 코드",
                example = "4/0AVMBsJh-authorization-code",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull(message = "인증 코드가 비어있습니다.")
        String code
){
}
