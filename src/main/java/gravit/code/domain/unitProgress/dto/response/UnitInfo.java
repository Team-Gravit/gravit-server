package gravit.code.domain.unitProgress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "유닛 정보 DTO")
public record UnitInfo(
        @Schema(
                description = "유닛 아이디",
                example = "1"
        )
        Long unitId,

        @Schema(
                description = "유닛 이름",
                example = "큐"
        )
        String unitName,

        @Schema(
                description = "총 레슨",
                example = "3"
        )
        Long totalLesson,

        @Schema(
                description = "푼 레슨",
                example = "2"
        )
        Long completedLesson
) {
}
