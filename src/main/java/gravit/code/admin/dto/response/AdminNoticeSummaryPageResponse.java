package gravit.code.admin.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "어드민 공지 요약 페이지 응답")
public class AdminNoticeSummaryPageResponse {

    @Schema(description = "현재 페이지 번호", example = "0")
    public int page;

    @Schema(description = "전체 페이지 수", example = "3")
    public int totalPages;

    @Schema(description = "다음 페이지 존재 여부", example = "true")
    public boolean hasNext;

    @Schema(description = "공지 요약 목록")
    public List<AdminNoticeSummaryResponse> contents;
}
