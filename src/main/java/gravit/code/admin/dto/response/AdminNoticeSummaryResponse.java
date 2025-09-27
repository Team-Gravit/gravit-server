package gravit.code.admin.dto.response;

import java.time.LocalDateTime;

public record AdminNoticeSummaryResponse(
        long id,
        String title,
        String summary,
        boolean pinned,
        LocalDateTime publishedAt
) {
}
