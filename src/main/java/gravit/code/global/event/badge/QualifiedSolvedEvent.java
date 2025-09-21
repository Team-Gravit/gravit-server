package gravit.code.global.event.badge;

public record QualifiedSolvedEvent(
        long userId,
        int seconds,
        int accuracy
) {
}
