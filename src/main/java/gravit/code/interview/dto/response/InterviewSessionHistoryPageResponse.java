package gravit.code.interview.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Schema(description = "응시 이력 페이지 응답")
@Builder(access = AccessLevel.PRIVATE)
public record InterviewSessionHistoryPageResponse(

        @Schema(
                description = "다음 페이지 존재 여부",
                example = "false",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        boolean hasNextPage,

        @Schema(
                description = "전체 페이지 수. 이력이 없으면 0",
                example = "3",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int totalPages,

        @Schema(
                description = "응시 이력 목록 (완료 세션만, 페이지당 10건)",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        List<InterviewSessionHistoryResponse> contents
) {
    public static InterviewSessionHistoryPageResponse of(
            boolean hasNextPage,
            int totalPages,
            List<InterviewSessionHistoryResponse> contents
    ) {
        return InterviewSessionHistoryPageResponse.builder()
                .hasNextPage(hasNextPage)
                .totalPages(totalPages)
                .contents(contents)
                .build();
    }
}
