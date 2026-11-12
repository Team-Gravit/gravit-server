package gravit.code.user.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record MyPageBannerResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImageNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String handle,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int level,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String currentLeague,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int consecutiveSolvedDays
) {
    public static MyPageBannerResponse of(
            int profileImageNumber,
            String nickname,
            String handle,
            int level,
            String currentLeague,
            int consecutiveSolvedDays
    ) {
        return MyPageBannerResponse.builder()
                .profileImageNumber(profileImageNumber)
                .nickname(nickname)
                .handle(handle)
                .level(level)
                .currentLeague(currentLeague)
                .consecutiveSolvedDays(consecutiveSolvedDays)
                .build();
    }
}
