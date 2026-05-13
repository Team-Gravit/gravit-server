package gravit.code.badge.dto.internal;

public record PlanetCompletionDto(
        long userId,
        String planetName,
        boolean allPlanetsCompleted
) {
}
