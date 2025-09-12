package gravit.code.mission.dto.common;

public record LessonMissionEvent(
        Long userId,
        Integer learningTime, // 풀이 시간(단위가 초라 Integer로)
        Integer accuracy
) {
}
