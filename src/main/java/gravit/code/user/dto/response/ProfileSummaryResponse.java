package gravit.code.user.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ProfileSummaryResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        UserLevelDetailResponse userLevelDetailResponse
) {
    public static ProfileSummaryResponse of(
            int profileImgNumber,
            String nickname,
            UserLevelDetailResponse userLevelDetailResponse
    ) {
        return ProfileSummaryResponse.builder()
                .profileImgNumber(profileImgNumber)
                .nickname(nickname)
                .userLevelDetailResponse(userLevelDetailResponse)
                .build();
    }
}
