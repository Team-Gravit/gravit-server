package gravit.code.problem.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.problem.domain.ProblemType;
import jakarta.validation.constraints.NotNull;

public record ProblemDetailResponse(

        long id,
        @NotNull
        ProblemType problemType,
        @NotNull
        String instruction,
        @NotNull
        String content,
        @JsonProperty("isBookmarked")
        boolean isBookmarked
) {
}
