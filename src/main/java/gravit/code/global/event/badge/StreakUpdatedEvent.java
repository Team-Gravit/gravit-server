package gravit.code.global.event.badge;

public record StreakUpdatedEvent(
        long userId,
        int steakCount
) {
}
