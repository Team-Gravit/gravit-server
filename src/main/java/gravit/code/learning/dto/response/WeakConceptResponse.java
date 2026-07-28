package gravit.code.learning.dto.response;

import gravit.code.learning.dto.internal.WeakUnitStatDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record WeakConceptResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int rank,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long unitId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String unitTitle,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String chapterTitle,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int wrongAnswerCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int wrongAnswerRate
) {
    public static WeakConceptResponse of(
            int rank,
            WeakUnitStatDto stat
    ) {
        int wrongAnswerCount = Math.toIntExact(stat.wrongAnswerCount());
        int wrongAnswerRate = stat.solvedProblemCount() == 0
                ? 0
                : Math.toIntExact(stat.wrongAnswerCount() * 100 / stat.solvedProblemCount());

        return WeakConceptResponse.builder()
                .rank(rank)
                .unitId(stat.unitId())
                .unitTitle(stat.unitTitle())
                .chapterTitle(stat.chapterTitle())
                .wrongAnswerCount(wrongAnswerCount)
                .wrongAnswerRate(wrongAnswerRate)
                .build();
    }
}
