package gravit.code.problem.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.problem.domain.ProblemType;
import io.swagger.v3.oas.annotations.media.Schema;

public record ProblemDetailResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long id,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        ProblemType problemType,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String instruction,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String content,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        @JsonProperty("isBookmarked")
        boolean isBookmarked
) {
}
