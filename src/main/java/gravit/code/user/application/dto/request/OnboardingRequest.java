package gravit.code.user.application.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record OnboardingRequest(
        @NotBlank
        String nickname,
        @NotNull
        int avatarId
){
}
