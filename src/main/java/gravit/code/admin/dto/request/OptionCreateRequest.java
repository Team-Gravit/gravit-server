package gravit.code.admin.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "옵션 생성 Request")
public record OptionCreateRequest(

        @Schema(
                description = "옵션 내용",
                example = "Spring Framework"
        )
        String content,

        @Schema(
                description = "옵션에 대한 설명",
                example = "Java 기반의 애플리케이션 프레임워크입니다."
        )
        String explanation,

        @Schema(
                description = "정답 여부",
                example = "true"
        )
        Boolean isAnswer,

        @Schema(
                description = "문제 ID",
                example = "1"
        )
        Long problemId
) {
}
