package gravit.code.global.event;

public record LessonCompletedEvent(
        long userId,
        long chapterId,
        int points,
        int accuracy
) {
}
