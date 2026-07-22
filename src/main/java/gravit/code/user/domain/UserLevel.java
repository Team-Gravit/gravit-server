package gravit.code.user.domain;

import gravit.code.user.dto.response.UserLevelDetailResponse;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class UserLevel {

    private static final double MAX_RATE = 100.0;

    @Column(name = "level", nullable = false)
    private int level;

    @Column(name = "xp", nullable = false)
    private int xp;

    @Builder(access = AccessLevel.PRIVATE)
    private UserLevel(
            int level,
            int xp
    ) {
        this.level = level;
        this.xp = xp;
    }

    public static UserLevel create(
            int level,
            int xp
    ) {
        return UserLevel.builder()
                .level(level)
                .xp(xp)
                .build();
    }

    public void updateXp(int xp){
        this.xp += xp;
        updateLevel(this.xp);
    }

    public UserLevelDetailResponse getUserLevelDetail() {
        Level currentLevel = Level.fromLevel(this.level);
        int maxXp = currentLevel.isMax() ? this.xp : currentLevel.getEndXp();

        return UserLevelDetailResponse.of(
                this.level,
                this.xp,
                maxXp,
                calculateLevelRate(this.xp)
        );
    }

    private void updateLevel(int totalXp){
        this.level = Level.fromXp(totalXp).getLevel();
    }

    private double calculateLevelRate(int xp){
        Level currentLevel = Level.fromXp(xp);
        if (currentLevel.isMax()) {
            return MAX_RATE;
        }

        int startXp = currentLevel.getStartXp();
        double rate = ((double)(xp - startXp) / (currentLevel.getEndXp() - startXp)) * MAX_RATE;
        return Math.round(rate * 10) / 10.0;
    }
}
