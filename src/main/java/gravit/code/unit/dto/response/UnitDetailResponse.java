package gravit.code.unit.dto.response;

import gravit.code.chapter.dto.response.ChapterSummary;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "유닛 페이지 조회 Response")
public record UnitDetailResponse(

        @Schema(description = "챕터 요약 정보")
        @NotNull
        ChapterSummary chapterSummary,

        @Schema(description = "유닛 상세 정보 목록")
        @NotNull
        List<UnitDetail> unitDetails
) {

    public static UnitDetailResponse create(
            ChapterSummary chapterSummary,
            List<UnitDetail> unitDetails
    ) {
        return UnitDetailResponse.builder()
                .chapterSummary(chapterSummary)
                .unitDetails(unitDetails)
                .build();
    }
}
