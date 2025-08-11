package gravit.code.domain.lesson.dto.response;

import gravit.code.domain.problem.dto.response.ProblemResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "레슨 조회 Response")
public record LessonResponse(
        List<ProblemResponse> problems,
        int totalProblems
) {

    public static LessonResponse create(List<ProblemResponse> problems){
        return LessonResponse.builder()
                .problems(problems)
                .totalProblems(problems.size())
                .build();
    }
}
