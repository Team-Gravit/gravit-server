package gravit.code.user.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record OnboardingRequest(

        @Schema(
                description = "닉네임 (2~8자, 한글, 영문, 숫자)",
                example = "그래빗",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotBlank(message = "닉네임은 필수입니다.")
        @Size(min = 2, max = 8, message = "닉네임은 2자 이상 8자 이하이어야 합니다.")
        @Pattern(regexp = "^[가-힣a-zA-Z0-9]+$", message = "닉네임은 공백이나 특수문자를 포함할 수 없습니다.")
        String nickname,

        @Schema(
                description = "프로필 사진 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull(message = "프로필 사진 번호는 필수입니다.")
        @Min(value = 1, message = "프로필 사진 번호는 1 이상이어야 합니다.")
        @Max(value = 19, message = "프로필 사진 번호는 19 이하여야 합니다.")
        Integer profilePhotoNumber
){
}
