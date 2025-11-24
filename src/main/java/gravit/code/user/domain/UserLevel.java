package gravit.code.user.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@NoArgsConstructor
@Getter
public class UserLevel {

    @Column(name = "level", nullable = false)
    private int level;

    @Column(name = "xp", nullable = false)
    private int xp;

    public UserLevel(
            int level,
            int xp
    ) {
        this.level = level;
        this.xp = xp;
    }

    public void updateXp(int xp){
        this.xp += xp;
        updateLevel(this.xp);
    }

    private void updateLevel(int totalXp){
        this.level = calculateLevel(totalXp);
    }

    private Integer calculateLevel(Integer totalXp){
        if(totalXp < 100) return 1;
        if(totalXp < 200) return 2;
        if(totalXp < 400) return 3;
        if(totalXp < 700) return 4;
        if(totalXp < 1100) return 5;
        if(totalXp < 1600) return 6;
        if(totalXp < 2200) return 7;
        if(totalXp < 2900) return 8;
        if(totalXp < 3700) return 9;
        else return 10;
    }

    public double calculateLevelRate(int xp){
        int levelStart;
        int levelEnd;

        if(xp < 100) {
            levelStart = 0;
            levelEnd = 100;
        } else if(xp < 200) {
            levelStart = 100;
            levelEnd = 200;
        } else if(xp < 400) {
            levelStart = 200;
            levelEnd = 400;
        } else if(xp < 700) {
            levelStart = 400;
            levelEnd = 700;
        } else if(xp < 1100) {
            levelStart = 700;
            levelEnd = 1100;
        } else if(xp < 1600) {
            levelStart = 1100;
            levelEnd = 1600;
        } else if(xp < 2200) {
            levelStart = 1600;
            levelEnd = 2200;
        } else if(xp < 2900) {
            levelStart = 2200;
            levelEnd = 2900;
        } else if(xp < 3700) {
            levelStart = 2900;
            levelEnd = 3700;
        } else {
            return 100.0;
        }

        double rate = ((double)(xp - levelStart) / (levelEnd - levelStart)) * 100;
        return Math.round(rate * 10) / 10.0;
    }

}
