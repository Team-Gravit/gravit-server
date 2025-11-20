package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 페이지 조회 Response")
public record LessonDetailResponse(
        @Schema(description = "챕터 요약 정보")
        ChapterSummary chapterSummary,

        @Schema(description = "레슨 요약 정보 목록")
        List<LessonSummary> lessonSummaries
) {
    public static LessonDetailResponse create(
            ChapterSummary chapterSummary,
            List<LessonSummary> lessonSummaries
    ){
        return LessonDetailResponse.builder()
                .chapterSummary(chapterSummary)
                .lessonSummaries(lessonSummaries)
                .build();
    }
}
