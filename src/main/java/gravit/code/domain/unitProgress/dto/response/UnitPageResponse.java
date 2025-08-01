package gravit.code.domain.unitProgress.dto.response;

import gravit.code.domain.lessonProgress.dto.response.LessonProgressSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "유닛 페이지 조회 Response")
public record UnitPageResponse(

        @Schema(
                description = "유닛 정보"
        )
        UnitProgressDetailResponse unitProgressDetailResponse,

        @Schema(
                description = "해당 유닛에 포함된 레슨 정보"
        )
        List<LessonProgressSummaryResponse> lessonProgressSummaryResponses
) {
    public static UnitPageResponse create(UnitProgressDetailResponse unitProgressDetailResponse, List<LessonProgressSummaryResponse> lessonProgressSummaryResponses) {
        return UnitPageResponse.builder()
                .unitProgressDetailResponse(unitProgressDetailResponse)
                .lessonProgressSummaryResponses(lessonProgressSummaryResponses)
                .build();
    }
}
