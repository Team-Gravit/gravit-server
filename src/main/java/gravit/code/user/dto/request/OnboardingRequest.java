package gravit.code.user.dto.request;

import jakarta.validation.constraints.*;

public record OnboardingRequest(

        @NotBlank(message = "닉네임은 필수입니다.")
        @Size(min = 2, max = 8, message = "닉네임은 2자 이상 8자 이하이어야 합니다.")
        @Pattern(regexp = "^[가-힣a-zA-Z0-9]+$", message = "닉네임은 공백이나 특수문자를 포함할 수 없습니다.")
        String nickname,

        @NotNull(message = "프로필 사진 번호는 필수입니다.")
        @Min(value = 1, message = "프로필 사진 번호는 1 이상이어야 합니다.")
        @Max(value = 10, message = "프로필 사진 번호는 10 이하여야 합니다.")
        Integer profilePhotoNumber
){
}
