package gravit.code.learning.dto.internal;

public record WeakUnitStatDto(
        long unitId,
        String unitTitle,
        String chapterTitle,
        long wrongAnswerCount,
        long solvedProblemCount
) {
}
