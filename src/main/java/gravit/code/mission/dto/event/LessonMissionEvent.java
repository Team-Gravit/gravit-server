package gravit.code.mission.dto.event;

public record LessonMissionEvent(
        long userId,
        long lessonId,
        int learningTime, // 풀이 시간(단위가 초라 int)
        int accuracy
) {
}
