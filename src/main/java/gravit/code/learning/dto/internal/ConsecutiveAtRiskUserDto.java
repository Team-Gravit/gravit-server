package gravit.code.learning.dto.internal;

public record ConsecutiveAtRiskUserDto(
        long userId,

        int consecutiveSolvedDays
) {
}
