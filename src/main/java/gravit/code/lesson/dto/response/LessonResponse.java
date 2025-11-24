package gravit.code.lesson.dto.response;

import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.unit.dto.response.UnitSummary;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 조회 Response")
public record LessonResponse(
        @Schema(description = "유닛 요약 정보")
        UnitSummary unitSummary,

        @Schema(description = "문제 목록")
        List<ProblemResponse> problems,

        @Schema(
                description = "전체 문제 수",
                example = "5"
        )
        int totalProblems
) {

    public static LessonResponse of(
            UnitSummary unitSummary,
            List<ProblemResponse> problems
    ){
        return LessonResponse.builder()
                .unitSummary(unitSummary)
                .problems(problems)
                .totalProblems(problems.size())
                .build();
    }
}
