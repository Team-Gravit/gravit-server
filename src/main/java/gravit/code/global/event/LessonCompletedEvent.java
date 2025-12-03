package gravit.code.global.event;

public record LessonCompletedEvent(
        long userId,
        long lessonId,
        long chapterId,
        int points,
        int accuracy,
        int learningTime
) {
}
