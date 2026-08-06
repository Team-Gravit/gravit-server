package gravit.code.chapter.dto.internal;

public record ChapterProgressRowDto(
        long chapterId,
        long totalLessons,
        long solvedLessons
) {
}
