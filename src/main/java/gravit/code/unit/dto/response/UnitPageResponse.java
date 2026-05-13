package gravit.code.unit.dto.response;

import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "유닛 페이지 조회 Response")
public record UnitPageResponse(

        @Schema(description = "챕터 요약 정보")
        @NotNull
        ChapterSummaryResponse chapterSummaryResponse,

        @Schema(description = "유닛 상세 정보 목록")
        @NotNull
        List<UnitDetailResponse> unitDetailResponses
) {

    public static UnitPageResponse create(
            ChapterSummaryResponse chapterSummaryResponse,
            List<UnitDetailResponse> unitDetailResponses
    ) {
        return UnitPageResponse.builder()
                .chapterSummaryResponse(chapterSummaryResponse)
                .unitDetailResponses(unitDetailResponses)
                .build();
    }
}
