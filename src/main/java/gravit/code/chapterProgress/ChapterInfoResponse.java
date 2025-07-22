package gravit.code.chapterProgress;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "챕터 정보 조회 Response")
public record ChapterInfoResponse(
        Long chapterId,
        String chapterName,
        String chapterDescription,
        Long totalUnits,
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
