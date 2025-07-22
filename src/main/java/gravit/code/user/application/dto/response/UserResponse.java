package gravit.code.user.application.dto.response;

import gravit.code.user.domain.User;
import lombok.Builder;

@Builder
public record UserResponse(
        Long userId,
        String nickname,
        String providerId
) {
    public static UserResponse from(User user) {
        return UserResponse.builder()
                .userId(user.getId())
                .nickname(user.getNickname())
                .providerId(user.getProviderId())
                .build();
    }
}
