package gravit.code.global.event.badge;

public record QualifiedSolvedEvent(
        Long userId,
        int seconds,
        int accuracy
) {
}
