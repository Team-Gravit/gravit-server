package gravit.code.learning.dto.request;

import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.problem.dto.request.ProblemSubmissionSaveRequest;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

import java.util.List;

@Schema(description = "레슨 풀이 저장 request")
public record LearningSubmissionSaveRequest(

        @Schema(
                description = "레슨 풀이 제출 결과"
        )
        @Valid
        @NotNull(message = "레슨 풀이 제출 결과가 비어있습니다.")
        LessonSubmissionSaveRequest lessonSubmissionSaveRequest,

        @Schema(
                description = "문제 풀이 제출 리스트"
        )
        @Valid
        @NotNull(message = "문제 풀이 제출 리스트가 비어있습니다.")
        List<ProblemSubmissionSaveRequest> problemSubmissionSaveRequests
) {}
