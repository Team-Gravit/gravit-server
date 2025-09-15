package gravit.code.notice.dto.response;

import gravit.code.notice.domain.Notice;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record NoticeSummaryResponse(
        Long id,
        String title,
        String summary,
        boolean pinned,
        LocalDateTime publishedAt
) {
    public static NoticeSummaryResponse from(Notice notice) {
        return NoticeSummaryResponse.builder()
                .id(notice.getId())
                .title(notice.getTitle())
                .summary(notice.getSummary())
                .pinned(notice.isPinned())
                .publishedAt(notice.getPublishedAt())
                .build();
    }
}
