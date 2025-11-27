package gravit.code.problem.dto.response;

import gravit.code.unit.dto.response.UnitSummary;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record WrongAnsweredProblemsResponse(

        @Schema(description = "유닛 요약 정보")
        @NotNull
        UnitSummary unitSummary,

        @Schema(description = "문제 목록")
        @NotNull
        List<ProblemResponse> problems,

        @Schema(
                description = "전체 문제 수",
                example = "5"
        )
        int totalProblems
) {
    public static WrongAnsweredProblemsResponse of(
            UnitSummary unitSummary,
            List<ProblemResponse> problems
    ){
        return WrongAnsweredProblemsResponse.builder()
                .unitSummary(unitSummary)
                .problems(problems)
                .totalProblems(problems.size())
                .build();
    }
}
