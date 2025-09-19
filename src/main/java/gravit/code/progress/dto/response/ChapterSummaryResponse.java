package gravit.code.progress.dto.response;

import lombok.Builder;

@Builder
public record ChapterSummaryResponse(
        long chapterId,
        String name,
        long totalUnits,
        long completedUnits
) {
    public static ChapterSummaryResponse create(long chapterId, String name, long totalUnits, long completedUnits) {
        return ChapterSummaryResponse.builder()
                .chapterId(chapterId)
                .name(name)
                .totalUnits(totalUnits)
                .completedUnits(completedUnits)
                .build();
    }
}
