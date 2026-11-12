package gravit.code.admin.dto.response;

import gravit.code.lesson.domain.Lesson;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record LessonListItemResponse(

        long lessonId,

        String title
) {
    public static LessonListItemResponse from(Lesson lesson) {
        return LessonListItemResponse.builder()
                .lessonId(lesson.getId())
                .title(lesson.getTitle())
                .build();
    }
}
