package gravit.code.bookmark.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "북마크 삭제 request")
public record BookmarkDeleteRequest(
        @Schema(
                description = "문제 아이디",
                example = "1"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        long problemId
) { }
