package gravit.code.interview.dto.response;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewTranscriptionStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTranscriptionResponse(

        @Schema(
                description = "문항 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "변환 상태. PENDING(변환 중) | COMPLETED(완료) | FAILED(실패). 변환을 요청하지 않았으면 null",
                example = "COMPLETED"
        )
        InterviewTranscriptionStatus status,

        @Schema(
                description = "변환된 텍스트. COMPLETED가 아니거나 말이 없었으면 null",
                example = "트랜잭션 격리 수준은 동시에 실행되는 트랜잭션이 서로의 변경을 어디까지 볼 수 있는지 정합니다."
        )
        String transcript
) {
    public static InterviewTranscriptionResponse from(InterviewAnswer answer) {
        return InterviewTranscriptionResponse.builder()
                .displayOrder(answer.getDisplayOrder())
                .status(answer.getTranscriptionStatus())
                .transcript(answer.getTranscript())
                .build();
    }
}
