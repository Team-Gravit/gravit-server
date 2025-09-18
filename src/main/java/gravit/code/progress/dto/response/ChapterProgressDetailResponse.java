package gravit.code.progress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "챕터 정보 조회 Response")
public record ChapterProgressDetailResponse(

        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        long chapterId,

        @Schema(
                description = "챕터 이름",
                example = "자료구조"
        )
        String name,

        @Schema(
                description = "챕터 설명",
                example = "큐, 스택, 힙과 같은 자료구조에 대해 학습합니다."
        )
        String description,

        @Schema(
                description = "총 유닛",
                example = "10"
        )
        long totalUnits,

        @Schema(
                description = "푼 유닛",
                example = "7"
        )
        long completedUnits
) {
    public static ChapterProgressDetailResponse create(long chapterId, String name, String description, long totalUnits, long completedUnits) {
        return ChapterProgressDetailResponse.builder()
                .chapterId(chapterId)
                .name(name)
                .description(description)
                .totalUnits(totalUnits)
                .completedUnits(completedUnits)
                .build();
    }
}
