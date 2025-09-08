package gravit.code.domain.progress.dto.response;

import lombok.Builder;

@Builder
public record ChapterSummaryResponse(
        Long chapterId,
        String name,
        Long totalUnits,
        Long completedUnits
) {
    public static ChapterSummaryResponse create(Long chapterId, String name, Long totalUnits, Long completedUnits) {
        return ChapterSummaryResponse.builder()
                .chapterId(chapterId)
                .name(name)
                .totalUnits(totalUnits)
                .completedUnits(completedUnits)
                .build();
    }
}
