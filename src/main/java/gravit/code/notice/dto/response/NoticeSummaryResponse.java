package gravit.code.notice.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

public record NoticeSummaryResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long id,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String title,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String summary,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean pinned,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime publishedAt
) {
}
