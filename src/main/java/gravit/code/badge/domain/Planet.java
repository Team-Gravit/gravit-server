package gravit.code.badge.domain;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.Getter;

@Getter
public enum Planet {
    EARTH(1, "지구"),
    MOON(2, "달"),
    MERCURY(3, "수성"),
    VENUS(4, "금성"),
    MARS(5, "화성"),
    JUPITER(6, "목성"),
    SATURN(7, "토성"),
    URANUS(8, "천왕성");

    private final long chapterId;
    private final String koName;

    Planet(
            long chapterId,
            String koName
    ) {
        this.chapterId = chapterId;
        this.koName = koName;
    }

    public static Planet getPlanetByChapterId(long chapterId) {
        for (Planet planet : Planet.values()) {
            if (planet.chapterId == chapterId) {
                return planet;
            }
        }
        throw new RestApiException(CustomErrorCode.NO_PLANET_MAPPING_CHAPTER_ID);
    }

    public static long getTotalPlanets(){
        return Planet.values().length;
    }
}
