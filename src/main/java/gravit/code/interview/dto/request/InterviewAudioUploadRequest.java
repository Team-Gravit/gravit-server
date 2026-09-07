package gravit.code.interview.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record InterviewAudioUploadRequest(

        @Schema(
                description = "문항 번호",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @Min(1)
        @Max(5)
        int displayOrder,

        @Schema(
                description = "업로드할 음성의 MIME 타입. audio/m4a, audio/mp4, audio/webm, audio/mpeg만 허용합니다.",
                example = "audio/m4a",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotBlank
        String contentType
) {
}
