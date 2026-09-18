package gravit.code.lesson.dto.internal;

public record SubmittedLessonDto(
        long lessonId,

        int accuracy,

        int learningTime
) {
}
