package gravit.code.domain.chapterProgress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "챕터 정보 조회 Response")
public record ChapterInfoResponse(

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
                example = "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다."
        )
        String chapterDescription,

        @Schema(
                description = "총 유닛",
                example = "10"
        )
        Long totalUnits,

        @Schema(
                description = "푼 유닛",
                example = "7"
        )
        Long completedUnits
) {
    public static ChapterInfoResponse create(Long chapterId, String chapterName, String chapterDescription, Long totalUnits, Long completedUnits) {
        return ChapterInfoResponse.builder()
                .chapterId(chapterId)
                .chapterName(chapterName)
                .chapterDescription(chapterDescription)
                .totalUnits(totalUnits)
                .completedUnits(completedUnits)
                .build();
    }
}
