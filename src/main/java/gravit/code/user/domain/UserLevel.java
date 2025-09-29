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

}
