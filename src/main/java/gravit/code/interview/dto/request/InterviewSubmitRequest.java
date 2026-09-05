package gravit.code.interview.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record InterviewSubmitRequest(

        @Schema(description = "문항별 답안. 문항 번호 1~5를 각각 한 번씩, 정확히 5건을 담습니다.")
        @NotNull
        @Size(min = 5, max = 5)
        @Valid
        List<InterviewAnswerSubmitRequest> answers
) {
}
