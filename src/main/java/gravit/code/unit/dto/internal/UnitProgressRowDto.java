package gravit.code.unit.dto.internal;

import gravit.code.unit.domain.UnitProgressStatus;
import gravit.code.unit.dto.response.UnitProgressSummaryResponse;

import static gravit.code.unit.domain.UnitProgressStatus.*;

public record UnitProgressRowDto(
        long unitId,

        String title,

        long totalLessons,

        long solvedLessons
) {
    public UnitProgressSummaryResponse toSummary(){
        UnitProgressStatus unitProgressStatus;

        if(solvedLessons == 0){
            unitProgressStatus = NOT_STARTED;
        }else if(solvedLessons >= totalLessons){
            unitProgressStatus = COMPLETED;
        }else{
            unitProgressStatus = IN_PROGRESS;
        }

        return UnitProgressSummaryResponse.of(unitId, title, unitProgressStatus);
    }
}
