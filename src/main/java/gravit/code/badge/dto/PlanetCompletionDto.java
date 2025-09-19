package gravit.code.badge.dto;

public record PlanetCompletionDto(
        long userId,
        String planetName,
        boolean allPlanetsCompleted
) {
}
