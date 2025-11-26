package gravit.code.wrongAnsweredNote.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "오답노트 삭제 request")
public record WrongAnsweredNoteDeleteRequest(
        @Schema(
                description = "문제 아이디",
                example = "1"
        )
        @NotNull(message = "문제 아이디가 비어있습니다.")
        Long problemId
) {
}
