package gravit.code.admin.dto.response;

import gravit.code.chapter.domain.Chapter;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ChapterDetailResponse(

        long chapterId,

        String title,

        String description,

        long unitCount
) {
    public static ChapterDetailResponse of(
            Chapter chapter,
            long unitCount
    ) {
        return ChapterDetailResponse.builder()
                .chapterId(chapter.getId())
                .title(chapter.getTitle())
                .description(chapter.getDescription())
                .unitCount(unitCount)
                .build();
    }
}
