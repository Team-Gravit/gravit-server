package gravit.code.unit.dto.internal;

import gravit.code.unit.dto.response.UnitProgressSummaryResponse;

public record UnitProgressRowDto(
    long unitId,
    String title,
    long totalLessons,
    long solvedLessons
) {
    public UnitProgressSummaryResponse toSummary(){
        boolean completed = totalLessons > 0 && totalLessons == solvedLessons;

        return UnitProgressSummaryResponse.of(unitId, title, completed);
    }
}
