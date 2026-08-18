package gravit.code.lesson.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 풀이 결과 저장 Response")
public record LessonSubmissionSaveResponse(

        @Schema(
                description = "생성된 레슨 제출 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long lessonSubmissionId
) {
    public static LessonSubmissionSaveResponse create(long lessonSubmissionId){
        return LessonSubmissionSaveResponse.builder()
                .lessonSubmissionId(lessonSubmissionId)
                .build();
    }
}
