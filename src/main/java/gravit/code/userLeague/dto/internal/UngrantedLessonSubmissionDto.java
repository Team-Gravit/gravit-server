package gravit.code.userLeague.dto.internal;

public record UngrantedLessonSubmissionDto(
        long userId,

        long lessonId,

        int accuracy
) {
}
