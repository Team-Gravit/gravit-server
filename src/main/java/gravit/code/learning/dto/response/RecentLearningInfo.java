package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
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
                description = "챕터 설명",
                example = "스택, 큐, 힙과 같은 자료구조에 대해 학습합니다."
        )
        String chapterDescription,

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
    public static RecentLearningInfo create(Long chapterId, String chapterName, String chapterDescription, Long totalUnits, Long completedUnits){
        return RecentLearningInfo.builder()
                .chapterId(chapterId)
                .chapterName(chapterName)
                .chapterDescription(chapterDescription)
                .totalUnits(totalUnits)
                .completedUnits(completedUnits)
                .build();
    }
}
