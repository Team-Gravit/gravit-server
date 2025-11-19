package gravit.code.learning.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;

import java.util.List;

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
