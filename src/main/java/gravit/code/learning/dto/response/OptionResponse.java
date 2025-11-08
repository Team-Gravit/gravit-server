package gravit.code.learning.dto.response;

import gravit.code.learning.domain.Option;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "선지 정보 Response")
public record OptionResponse(

        @Schema(
                description = "선지 아이디",
                example = "1"
        )
        long optionId,

        @Schema(
                description = "내용",
                example = "tail 포인터가 더 빠른 접근을 제공"
        )
        String content,

        @Schema(
                description = "설명",
                example = "실제로 tail 포인터를 활용했을 때 속도가 더 빠르다."
        )
        String explanation,

        @Schema(
                description = "정답 여부",
                example = "true"
        )
        boolean isAnswer,

        @Schema(
                description = "문제 아이디",
                example = "1"
        )
        long problemId
) {
    public static OptionResponse from(Option option) {
        return OptionResponse.builder()
                .optionId(option.getId())
                .problemId(option.getProblemId())
                .content(option.getContent())
                .explanation(option.getExplanation())
                .isAnswer(option.isAnswer())
                .build();
    }
}
