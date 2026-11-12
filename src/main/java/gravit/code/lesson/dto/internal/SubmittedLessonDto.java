package gravit.code.lesson.dto.internal;

public record SubmittedLessonDto(
        long lessonId,

        long chapterId,

        int accuracy,

        int learningTime
) {
}
