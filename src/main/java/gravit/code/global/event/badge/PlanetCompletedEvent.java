package gravit.code.global.event.badge;

public record PlanetCompletedEvent(
        Long userId,
        Long chapterId,
        long beforeCount,
        long afterCount,
        long totalUnitCount
) {
}
