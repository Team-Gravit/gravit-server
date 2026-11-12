package gravit.code.interview.dto.request;

import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewStack;
import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record InterviewSessionCreateRequest(

        @Schema(
                description = "답변 입력 방식",
                example = "TEXT",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull(message = "답변 입력 방식이 비어있습니다.")
        InterviewInputType inputType,

        @Schema(
                description = "면접 모드",
                example = "COMMON_CS",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull(message = "면접 모드가 비어있습니다.")
        InterviewMode mode,

        @Schema(
                description = "난이도. 5문항 모두 이 난이도로 출제됩니다.",
                example = "NORMAL",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotNull(message = "난이도가 비어있습니다.")
        InterviewDifficulty difficulty,

        @Schema(
                description = "스택. 직군(JOB_SPECIFIC) 모드에서만 담고, 공통 CS 모드는 비워야 합니다.",
                example = "JAVA_SPRING_BOOT"
        )
        InterviewStack stack,

        @Schema(
                description = "주제 목록. 공통 CS(COMMON_CS) 모드에서만 중복 없이 1~5개를 담고, 직군 모드는 비워야 합니다.",
                example = "[\"DATA_STRUCTURE\", \"NETWORK\"]"
        )
        List<@NotNull(message = "주제 목록에 빈 값이 있습니다.") InterviewTopic> topics
) {
}
