package gravit.code.global.event;

public record LessonCompletedEvent(
        long userId,
        int points,
        int accuracy
) {
}
