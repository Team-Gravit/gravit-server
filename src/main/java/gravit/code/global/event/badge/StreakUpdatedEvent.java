package gravit.code.global.event.badge;

public record StreakUpdatedEvent(
        Long userId,
        int steakCount
) {
}
