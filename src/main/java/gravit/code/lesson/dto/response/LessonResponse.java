package gravit.code.lesson.dto.response;

import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 조회 Response")
public record LessonResponse(

        @Schema(
                description = "유닛 요약 정보",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        UnitSummaryResponse unitSummaryResponse,

        @Schema(
                description = "문제 목록",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<ProblemResponse> problems,

        @Schema(
                description = "전체 문제 수",
                example = "5",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int totalProblems
) {

    public static LessonResponse of(
            UnitSummaryResponse unitSummaryResponse,
            List<ProblemResponse> problems
    ){
        return LessonResponse.builder()
                .unitSummaryResponse(unitSummaryResponse)
                .problems(problems)
                .totalProblems(problems.size())
                .build();
    }
}
