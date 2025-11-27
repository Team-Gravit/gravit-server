package gravit.code.user.dto.response;

import gravit.code.user.domain.UserLevel;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UserLevelDetail(

        @Schema(
                description = "레벨",
                example = "5"
        )
        int level,

        @Schema(
                description = "경험치",
                example = "850"
        )
        int xp,

        @Schema(
                description = "현재 레벨 진행률 (%)",
                example = "75.0"
        )
        double levelRate
) {
    public static UserLevelDetail of(UserLevel userLevel, double levelRate){
        return UserLevelDetail.builder()
                .level(userLevel.getLevel())
                .xp(userLevel.getXp())
                .levelRate(levelRate)
                .build();
    }
}
