package gravit.code.user.dto.response;

import gravit.code.user.domain.UserLevel;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record UserLevelDetail(
        int level,
        int xp,
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
