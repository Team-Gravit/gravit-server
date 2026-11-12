package gravit.code.admin.dto.request;

import jakarta.validation.Valid;

public record SubjectiveProblemUpdateRequest(

        String instruction,

        String content,

        @Valid
        SubjectiveAnswerUpdateRequest answer
) {
}
