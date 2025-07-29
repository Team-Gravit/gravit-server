package gravit.code.domain.chapterProgress.dto.response;

import lombok.Builder;

@Builder
public record ChapterInfo(
        Long chapterId,
        String chapterName,
        Long totalUnits,
        Long completedUnits
) {
    public static ChapterInfo create(Long chapterId, String chapterName, Long totalUnits, Long completedUnits) {
        return ChapterInfo.builder()
                .chapterId(chapterId)
                .chapterName(chapterName)
                .totalUnits(totalUnits)
                .completedUnits(completedUnits)
                .build();
    }
}
