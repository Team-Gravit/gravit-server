package gravit.code.bookmark.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "북마크 저장 request")
public record BookmarkSaveRequest(

        @Schema(
                description = "문제 아이디",
                example = "1"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        Long problemId

) {
}
