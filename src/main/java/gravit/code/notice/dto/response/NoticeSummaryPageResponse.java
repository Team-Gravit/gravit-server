package gravit.code.notice.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "공지 요약 페이지 응답")
public record NoticeSummaryPageResponse(

        @Schema(
                description = "현재 페이지 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int page,

        @Schema(
                description = "전체 페이지 수",
                example = "5",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int totalPages,

        @Schema(
                description = "다음 페이지 존재 여부",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean hasNext,

        @Schema(
                description = "전체 공지 개수",
                example = "42",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long totalElements,

        @Schema(
                description = "공지 요약 목록",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<NoticeSummaryResponse> contents
) {
}
