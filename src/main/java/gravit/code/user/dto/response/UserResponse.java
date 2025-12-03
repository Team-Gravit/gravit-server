package gravit.code.user.dto.response;

import gravit.code.user.domain.User;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

@Builder
public record UserResponse(
        long userId,
        int profileImgNumber,
        String nickname,
        String providerId
) {
    public static UserResponse from(User user) {
        return UserResponse.builder()
                .userId(user.getId())
                .profileImgNumber(user.getProfileImgNumber())
                .nickname(user.getNickname())
                .providerId(user.getProviderId())
                .build();
    }
}
