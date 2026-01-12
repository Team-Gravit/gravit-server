package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LearningDetail(

        @Schema(
                description = "연속 학습일",
                example = "10"
        )
        int consecutiveSolvedDays,

        @Schema(
                description = "행성 정복율",
                example = "70"
        )
        double planetConquestRate,

        @Schema(
                description = "챕터 아이디",
                example = "5"
        )
        long recentSolvedChapterId,

        @Schema(
                description = "챕터 이름",
                example = "자료구조"
        )
        @NotNull
        String recentSolvedChapterTitle,

        @Schema(
                description = "챕터 설명",
                example = "스택, 큐, 힙과 같은 자료구조에 대해 학습합니다."
        )
        @NotNull
        String recentSolvedChapterDescription,

        @Schema(
                description = "최근 학습 챕터 진행률 (%)",
                example = "65.5"
        )
        double recentSolvedChapterProgressRate

) {
    public LearningDetail withRecentSolvedChapterProgressRate(double recentSolvedChapterProgressRate) {
        return LearningDetail.builder()
                .consecutiveSolvedDays(this.consecutiveSolvedDays)
                .planetConquestRate(this.planetConquestRate)
                .recentSolvedChapterId(this.recentSolvedChapterId)
                .recentSolvedChapterTitle(this.recentSolvedChapterTitle)
                .recentSolvedChapterDescription(this.recentSolvedChapterDescription)
                .recentSolvedChapterProgressRate(recentSolvedChapterProgressRate)
                .build();
    }

}
