package gravit.code.domain.recentLearning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "최근 학습 정보 Response")
public record RecentLearningInfo(
        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        Long chapterId,

        @Schema(
                description = "챕터 이름",
                example = "자료구조"
        )
        String chapterName,

        @Schema(
                description = "총 유닛수",
                example = "10"
        )
        Long totalUnits,

        @Schema(
                description = "푼 유닛수",
                example = "2"
        )
        Long completedUnits
) {
}
