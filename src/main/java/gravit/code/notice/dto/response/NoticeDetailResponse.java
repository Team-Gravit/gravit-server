package gravit.code.notice.dto.response;

import gravit.code.notice.domain.Notice;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record NoticeDetailResponse(

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long id,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String title,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String content,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String authorName,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime createdAt,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime updatedAt,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String status,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        boolean pinned,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LocalDateTime publishedAt,

        @Schema(
                description = "이전 공지. 바로 더 최근에 게시된 공지이며, 고정 공지는 순서에서 빠진다. 고정 공지 상세이거나 가장 최근 공지면 null",
                nullable = true,
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        NoticeNeighborResponse prev,

        @Schema(
                description = "다음 공지. 바로 더 오래전에 게시된 공지이며, 고정 공지는 순서에서 빠진다. 고정 공지 상세이거나 가장 오래된 공지면 null",
                nullable = true,
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        NoticeNeighborResponse next
) {
    public static NoticeDetailResponse of(
            Notice notice,
            NoticeNeighborResponse prev,
            NoticeNeighborResponse next
    ) {
        return NoticeDetailResponse.builder()
                .id(notice.getId())
                .title(notice.getTitle())
                .content(notice.getContent())
                .authorName(notice.getAuthor().getNickname())
                .createdAt(notice.getCreatedAt())
                .updatedAt(notice.getUpdatedAt())
                .publishedAt(notice.getPublishedAt())
                .status(notice.getStatus().name())
                .pinned(notice.isPinned())
                .prev(prev)
                .next(next)
                .build();
    }
}
