package gravit.code.inquiry.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "문의 요약 페이지 응답")
public class InquirySummaryPageResponse {

    @Schema(
            description = "현재 페이지 번호",
            example = "1",
            requiredMode = Schema.RequiredMode.REQUIRED
    )
    public int page;

    @Schema(
            description = "전체 페이지 수",
            example = "3",
            requiredMode = Schema.RequiredMode.REQUIRED
    )
    public int totalPages;

    @Schema(
            description = "다음 페이지 존재 여부",
            example = "true",
            requiredMode = Schema.RequiredMode.REQUIRED
    )
    public boolean hasNext;

    @Schema(
            description = "전체 문의 개수",
            example = "27",
            requiredMode = Schema.RequiredMode.REQUIRED
    )
    public long totalElements;

    @Schema(
            description = "문의 요약 목록",
            requiredMode = Schema.RequiredMode.REQUIRED
    )
    public List<InquirySummaryResponse> contents;
}
