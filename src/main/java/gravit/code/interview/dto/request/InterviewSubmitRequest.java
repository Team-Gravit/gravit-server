package gravit.code.interview.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record InterviewSubmitRequest(

        @Schema(description = "문항별 답안. 문항 번호 1~5를 각각 한 번씩, 정확히 5건을 담습니다.")
        @NotNull(message = "답안 목록이 비어있습니다.")
        @Size(min = 5, max = 5, message = "답안은 정확히 5건이어야 합니다.")
        @Valid
        List<@NotNull(message = "답안 목록에 빈 값이 있습니다.") InterviewAnswerSubmitRequest> answers
) {
}
