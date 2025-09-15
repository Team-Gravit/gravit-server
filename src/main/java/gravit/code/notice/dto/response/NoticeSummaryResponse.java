package gravit.code.notice.dto.response;

import java.time.LocalDateTime;

public record NoticeSummaryResponse(
        Long id,
        String title,
        String summary,
        boolean pinned,
        LocalDateTime publishedAt
) {
}
