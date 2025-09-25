package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "레슨 조회 Response")
public record LessonResponse(
        String lessonName,
        List<ProblemResponse> problems,
        int totalProblems
) {

    public static LessonResponse create(
            String lessonName,
            List<ProblemResponse> problems
    ){
        return LessonResponse.builder()
                .lessonName(lessonName)
                .problems(problems)
                .totalProblems(problems.size())
                .build();
    }
}
