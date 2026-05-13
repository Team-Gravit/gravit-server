package gravit.code.lesson.dto.response;

import gravit.code.unit.dto.response.UnitSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 페이지 조회 Response")
public record LessonDetailResponse(

        @Schema(description = "유닛 요약 정보")
        @NotNull
        UnitSummaryResponse unitSummaryResponse,

        @Schema(
                description = "북마크 풀이 가능 여부",
                example = "true"
        )
        @NotNull
        boolean bookmarkAccessible,

        @Schema(
                description = "오답노트 풀이 가능 여부",
                example = "true"
        )
        @NotNull
        boolean wrongAnsweredNoteAccessible,

        @Schema(
                description = "유닛 아이디",
                example = "1"
        )
        long unitId,

        @Schema(description = "레슨 요약 정보 목록")
        @NotNull
        List<LessonSummaryResponse> lessonSummaries
) {
    public static LessonDetailResponse create(
            UnitSummaryResponse unitSummaryResponse,
            boolean bookmarkAccessible,
            boolean wrongAnsweredNoteAccessible,
            long unitId,
            List<LessonSummaryResponse> lessonSummaries
    ){
        return LessonDetailResponse.builder()
                .unitSummaryResponse(unitSummaryResponse)
                .bookmarkAccessible(bookmarkAccessible)
                .wrongAnsweredNoteAccessible(wrongAnsweredNoteAccessible)
                .unitId(unitId)
                .lessonSummaries(lessonSummaries)
                .build();
    }
}
