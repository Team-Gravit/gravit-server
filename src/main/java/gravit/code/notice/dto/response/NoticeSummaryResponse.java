package gravit.code.notice.dto.response;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

public record NoticeSummaryResponse(

        long id,
        @NotNull
        String title,
        @NotNull
        String summary,
        boolean pinned,
        @NotNull
        LocalDateTime publishedAt
) {
}
