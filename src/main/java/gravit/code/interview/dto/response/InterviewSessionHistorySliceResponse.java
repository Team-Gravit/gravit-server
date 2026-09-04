package gravit.code.interview.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "응시 이력 슬라이스 응답")
public record InterviewSessionHistorySliceResponse(

        @Schema(
                description = "다음 페이지 존재 여부",
                example = "false",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean hasNextPage,

        @Schema(
                description = "응시 이력 목록 (완료 세션만, 페이지당 10건)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewSessionHistoryResponse> contents
) {
}
