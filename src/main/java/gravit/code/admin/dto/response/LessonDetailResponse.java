package gravit.code.admin.dto.response;

import gravit.code.lesson.domain.Lesson;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LessonDetailResponse(

        long lessonId,

        long unitId,

        String title,

        long problemCount
) {
    public static LessonDetailResponse of(
            Lesson lesson,
            long problemCount
    ) {
        return LessonDetailResponse.builder()
                .lessonId(lesson.getId())
                .unitId(lesson.getUnitId())
                .title(lesson.getTitle())
                .problemCount(problemCount)
                .build();
    }
}
