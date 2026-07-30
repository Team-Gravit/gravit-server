package gravit.code.chapter.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record ChapterBriefResponse(

        @Schema(
                description = "챕터 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long chapterId,

        @Schema(
                description = "챕터명",
                example = "자료구조",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String title
) {
}
