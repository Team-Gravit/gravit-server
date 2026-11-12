package gravit.code.notice.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record NoticeNeighborResponse(

        @Schema(
                description = "공지 아이디",
                example = "125",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long id,

        @Schema(
                description = "공지 제목",
                example = "11월 업데이트 안내",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String title
) {
}
