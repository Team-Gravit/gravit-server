package gravit.code.user.dto.response;

import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UserLevelDetailResponse(
        int level,
        int currentXp,
        int maxXp,
        double levelRate
) {
    public static UserLevelDetailResponse of(
            int level,
            int currentXp,
            int maxXp,
            double levelRate
    ) {
        return UserLevelDetailResponse.builder()
                .level(level)
                .currentXp(currentXp)
                .maxXp(maxXp)
                .levelRate(levelRate)
                .build();
    }
}
