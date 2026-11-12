package gravit.code.interview.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionCreateResponse(

        @Schema(
                description = "생성된 면접 세션 아이디",
                example = "12",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long sessionId
) {
    public static InterviewSessionCreateResponse from(long sessionId) {
        return InterviewSessionCreateResponse.builder()
                .sessionId(sessionId)
                .build();
    }
}
