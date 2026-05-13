package gravit.code.learning.dto.response;

import gravit.code.unit.dto.response.UnitProgressSummaryResponse;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record LearningDetailResponse(
        int consecutiveSolvedDays,
        long recentSolvedChapterId,
        String recentSolvedChapterTitle,
        double recentSolvedChapterProgressRate,
        List<UnitProgressSummaryResponse> units
) {
    public static LearningDetailResponse of(
            int consecutiveSolvedDays,
            long recentSolvedChapterId,
            String recentSolvedChapterTitle,
            double recentSolvedChapterProgressRate,
            List<UnitProgressSummaryResponse> units
    ){
        return LearningDetailResponse.builder()
                .consecutiveSolvedDays(consecutiveSolvedDays)
                .recentSolvedChapterId(recentSolvedChapterId)
                .recentSolvedChapterTitle(recentSolvedChapterTitle)
                .recentSolvedChapterProgressRate(recentSolvedChapterProgressRate)
                .units(units)
                .build();
    }
}
