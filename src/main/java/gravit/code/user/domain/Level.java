package gravit.code.user.domain;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public enum Level {

    LEVEL_1(1, 0),
    LEVEL_2(2, 100),
    LEVEL_3(3, 200),
    LEVEL_4(4, 400),
    LEVEL_5(5, 700),
    LEVEL_6(6, 1100),
    LEVEL_7(7, 1600),
    LEVEL_8(8, 2200),
    LEVEL_9(9, 2900),
    LEVEL_10(10, 3700);

    private static final Level[] VALUES = values();

    private final int level;
    private final int startXp;

    public static Level fromXp(int totalXp) {
        Level found = VALUES[0];

        for (Level candidate : VALUES) {
            if (totalXp < candidate.startXp) {
                break;
            }
            found = candidate;
        }

        return found;
    }

    public static Level fromLevel(int level) {
        for (Level candidate : VALUES) {
            if (candidate.level == level) {
                return candidate;
            }
        }

        throw new IllegalArgumentException("존재하지 않는 레벨입니다: " + level);
    }

    public boolean isMax() {
        return ordinal() == VALUES.length - 1;
    }

    public int getEndXp() {
        if (isMax()) {
            throw new IllegalStateException("최고 레벨은 상한 XP가 없습니다: " + this.level);
        }

        return VALUES[ordinal() + 1].startXp;
    }
}
