package gravit.code.unit.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record RecommendedUnitResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long unitId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String unitTitle,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long chapterId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String chapterTitle
) {
}