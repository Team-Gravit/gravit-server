package gravit.code.badge.domain;

import lombok.Getter;

@Getter
public enum BadgeType {
    PLANET_COMPLETE("행성 완료"),
    STREAK_LEARNING("연속 학습"),
    SPEED_OF_SOLVED("풀이 속도"),
    COMPLETE_MISSION("미션 완료");

    private final String name;

    BadgeType(String name) {
        this.name = name;
    }

}
