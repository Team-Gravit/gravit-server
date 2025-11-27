package gravit.code.admin.dto.response;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

public record AdminNoticeSummaryResponse(

        long id,
        @NotNull
        String title,
        @NotNull
        String summary,
        boolean pinned,
        LocalDateTime publishedAt
) {
}
