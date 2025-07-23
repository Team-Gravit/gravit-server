package gravit.code.domain.user.dto.response;

import gravit.code.domain.user.domain.User;
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
