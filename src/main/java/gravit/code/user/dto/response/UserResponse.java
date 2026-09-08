package gravit.code.user.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.user.domain.User;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UserResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long userId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String providerId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        @JsonProperty("isOnboarded")
        boolean isOnboarded
) {
    public static UserResponse from(User user) {
        return UserResponse.builder()
                .userId(user.getId())
                .profileImgNumber(user.getProfileImgNumber())
                .nickname(user.getNickname())
                .providerId(user.getProviderId())
                .isOnboarded(user.isOnboarded())
                .build();
    }
}
