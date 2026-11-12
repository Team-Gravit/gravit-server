package gravit.code.unit.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record UnitSummaryResponse(

        @Schema(
                description = "유닛 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long unitId,

        @Schema(
                description = "챕터 안에서의 유닛 순서 (1부터 시작)",
                example = "2",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "유닛명",
                example = "연결리스트",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String title,

        @Schema(
                description = "유닛 설명",
                example = "배열과 연결리스트에 대해 학습합니다.",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String description
) {
}
