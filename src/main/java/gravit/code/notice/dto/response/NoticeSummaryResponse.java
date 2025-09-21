package gravit.code.notice.dto.response;

import java.time.LocalDateTime;

public record NoticeSummaryResponse(
        long id,
        String title,
        String summary,
        boolean pinned,
        LocalDateTime publishedAt
) {
}
