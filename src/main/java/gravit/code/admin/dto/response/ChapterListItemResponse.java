package gravit.code.admin.dto.response;

import gravit.code.chapter.domain.Chapter;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record ChapterListItemResponse(

        long chapterId,

        String title,

        String description
) {
    public static ChapterListItemResponse from(Chapter chapter) {
        return ChapterListItemResponse.builder()
                .chapterId(chapter.getId())
                .title(chapter.getTitle())
                .description(chapter.getDescription())
                .build();
    }
}
