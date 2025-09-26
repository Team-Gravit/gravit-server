package gravit.code.learning.dto.response;

import gravit.code.learning.dto.LearningAdditionalInfo;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "레슨 조회 Response")
public record LessonResponse(
        long chapterId,
        String lessonName,
        List<ProblemResponse> problems,
        int totalProblems
) {

    public static LessonResponse create(
            LearningAdditionalInfo learningAdditionalInfo,
            List<ProblemResponse> problems
    ){
        return LessonResponse.builder()
                .chapterId(learningAdditionalInfo.chapterId())
                .lessonName(learningAdditionalInfo.lessonName())
                .problems(problems)
                .totalProblems(problems.size())
                .build();
    }
}
