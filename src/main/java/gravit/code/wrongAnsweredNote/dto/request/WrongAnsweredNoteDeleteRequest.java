package gravit.code.wrongAnsweredNote.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "오답노트 삭제 request")
public record WrongAnsweredNoteDeleteRequest(

        @Schema(
                description = "문제 아이디",
                example = "1"
        )
        long problemId
) {
}
