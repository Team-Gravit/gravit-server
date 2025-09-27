package gravit.code.progress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "유닛 페이지 조회 Response")
public record UnitDetail(

        @Schema(
                description = "유닛 정보"
        )
        UnitProgressDetailResponse unitProgressDetailResponse,

        @Schema(
                description = "해당 유닛에 포함된 레슨 정보"
        )
        List<LessonProgressSummaryResponse> lessonProgressSummaryResponses
) {
    public static UnitDetail create(
            UnitProgressDetailResponse unitProgressDetailResponse,
            List<LessonProgressSummaryResponse> lessonProgressSummaryResponses
    ) {
        return UnitDetail.builder()
                .unitProgressDetailResponse(unitProgressDetailResponse)
                .lessonProgressSummaryResponses(lessonProgressSummaryResponses)
                .build();
    }
}
