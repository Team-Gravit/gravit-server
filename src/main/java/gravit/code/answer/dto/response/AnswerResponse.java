package gravit.code.answer.dto.response;

import gravit.code.answer.domain.Answer;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.Arrays;
import java.util.List;

@Schema(description = "주관식 정답 Response")
public record AnswerResponse(
        @Schema(
                description = "정답 내용",
                example = "2"
        )
        List<String> contents,

        @Schema(
                description = "정답 해설",
                example = "큐는 FIFO 구조로 먼저 들어간 원소가 먼저 나옵니다."
        )
        String explanation
) {
        public static AnswerResponse from(Answer answer) {
                return new AnswerResponse(
                        Arrays.asList(answer.getContent().split(",")),
                        answer.getExplanation()
                );
        }
}
