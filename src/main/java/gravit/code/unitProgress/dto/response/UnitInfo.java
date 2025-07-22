package gravit.code.unitProgress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "유닛 정보 DTO")
public record UnitInfo(
        Long unitId,
        String unitName,
        Long totalLesson,
        Long completedLesson
) {
}
