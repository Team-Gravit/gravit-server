package gravit.code.interview.dto.response;

import gravit.code.interview.dto.internal.InterviewSessionQuestionDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionQuestionResponse(

        @Schema(
                description = "문항 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int displayOrder,

        @Schema(
                description = "문제 본문",
                example = "퀵 정렬의 동작 방식과 평균 시간복잡도를 설명해 주세요.",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String content,

        @Schema(
                description = "질문 음성 재생 URL(presigned GET). 음성이 없는 문항은 null. 발급 후 30분 동안 유효",
                example = "https://gravit-interview-audio.s3.ap-northeast-2.amazonaws.com/interview-question/1.mp3?X-Amz-Algorithm=...",
                nullable = true
        )
        String audioUrl
) {
    public static InterviewSessionQuestionResponse of(
            InterviewSessionQuestionDto question,
            String audioUrl
    ) {
        return InterviewSessionQuestionResponse.builder()
                .displayOrder(question.displayOrder())
                .content(question.content())
                .audioUrl(audioUrl)
                .build();
    }
}
