package gravit.code.interview.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewTranscriptionsResponse(

        @Schema(
                description = "면접 세션 아이디",
                example = "12",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId,

        @Schema(
                description = "문항 번호 오름차순으로 정렬된 5문항의 변환 결과",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewTranscriptionResponse> transcriptions
) {
    public static InterviewTranscriptionsResponse of(
            long sessionId,
            List<InterviewTranscriptionResponse> transcriptions
    ) {
        return InterviewTranscriptionsResponse.builder()
                .sessionId(sessionId)
                .transcriptions(transcriptions)
                .build();
    }
}
