package gravit.code.learning.dto.request;

import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.problem.dto.request.ProblemSubmissionRequest;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;

import java.util.List;

@Schema(description = "레슨 풀이 저장 request")
public record LearningSubmissionSaveRequest(

        @Schema(
                description = "레슨 풀이 제출 리스트"
        )
        LessonSubmissionSaveRequest lessonSubmissionSaveRequest,

        @Schema(
                description = "문제 풀이 제출 리스트"
        )
        @Valid
        List<ProblemSubmissionRequest> problemSubmissionRequests
) {}
