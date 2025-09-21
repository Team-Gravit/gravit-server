package gravit.code.global.event.badge;

public record PlanetCompletedEvent(
        long userId,
        long chapterId,
        long beforeCount,
        long afterCount,
        long totalUnitCount
) {
}
