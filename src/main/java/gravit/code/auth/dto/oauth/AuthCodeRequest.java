package gravit.code.auth.dto.oauth;

import jakarta.validation.constraints.NotNull;

public record AuthCodeRequest(

        @NotNull(message = "인증 코드가 비어있습니다.")
        String code
){
}
