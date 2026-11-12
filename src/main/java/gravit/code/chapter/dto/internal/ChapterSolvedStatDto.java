package gravit.code.chapter.dto.internal;

public record ChapterSolvedStatDto(
        long chapterId,

        String chapterTitle,

        long solvedLessonCount
) {
}
