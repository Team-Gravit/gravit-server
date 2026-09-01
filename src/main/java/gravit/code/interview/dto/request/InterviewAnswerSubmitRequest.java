package gravit.code.interview.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Size;

@Schema(description = "면접 답변 제출 Request")
public record InterviewAnswerSubmitRequest(

        @Schema(
                description = "답변 본문. 비우면 무응답으로 기록됩니다",
                example = "인덱스는 조회 성능을 높이기 위한 자료구조입니다."
        )
        @Size(max = 2000)
        String content
) {
}
