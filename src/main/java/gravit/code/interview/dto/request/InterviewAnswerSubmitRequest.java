package gravit.code.interview.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record InterviewAnswerSubmitRequest(

        @Schema(
                description = "문항 번호",
                example = "1"
        )
        @Min(1)
        @Max(5)
        int displayOrder,

        @Schema(
                description = "답변 텍스트. null 또는 공백이면 무응답으로 저장됩니다.",
                example = "퀵 정렬은 피벗을 기준으로 배열을 분할해 재귀적으로 정렬합니다."
        )
        String content,

        @Schema(
                description = "음성 키. VOICE 세션에서만 값을 담고 TEXT 세션은 null이어야 합니다.",
                example = "interview/12/1.m4a"
        )
        String audioKey
) {
}
