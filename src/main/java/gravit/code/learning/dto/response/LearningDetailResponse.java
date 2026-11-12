package gravit.code.learning.dto.response;

import gravit.code.unit.dto.response.UnitProgressSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record LearningDetailResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        long recentSolvedChapterId,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String recentSolvedChapterTitle,

        @Schema(
                description = "최근 학습한 챕터 진행률 (0~100, 소수점 버림). 푼 레슨 수 / 챕터 전체 레슨 수 x 100",
                example = "33.0",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        double recentSolvedChapterProgressRate,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<UnitProgressSummaryResponse> units
) {
    public static LearningDetailResponse of(
            long recentSolvedChapterId,
            String recentSolvedChapterTitle,
            double recentSolvedChapterProgressRate,
            List<UnitProgressSummaryResponse> units
    ){
        return LearningDetailResponse.builder()
                .recentSolvedChapterId(recentSolvedChapterId)
                .recentSolvedChapterTitle(recentSolvedChapterTitle)
                .recentSolvedChapterProgressRate(recentSolvedChapterProgressRate)
                .units(units)
                .build();
    }
}
