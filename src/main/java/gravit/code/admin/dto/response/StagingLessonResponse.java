package gravit.code.admin.dto.response;

import gravit.code.admin.domain.staging.LessonStaging;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record StagingLessonResponse(

        long lessonId,

        String title
) {
    public static StagingLessonResponse from(LessonStaging lesson) {
        return StagingLessonResponse.builder()
                .lessonId(lesson.getId())
                .title(lesson.getTitle())
                .build();
    }
}
