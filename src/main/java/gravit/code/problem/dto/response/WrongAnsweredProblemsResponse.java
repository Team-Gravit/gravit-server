package gravit.code.problem.dto.response;

import gravit.code.unit.dto.response.UnitSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record WrongAnsweredProblemsResponse(

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
    public static WrongAnsweredProblemsResponse of(
            UnitSummaryResponse unitSummaryResponse,
            List<ProblemResponse> problems
    ){
        return WrongAnsweredProblemsResponse.builder()
                .unitSummaryResponse(unitSummaryResponse)
                .problems(problems)
                .totalProblems(problems.size())
                .build();
    }
}
