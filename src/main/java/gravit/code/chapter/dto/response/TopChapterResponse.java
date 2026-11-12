package gravit.code.chapter.dto.response;

import gravit.code.chapter.dto.internal.ChapterSolvedStatDto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record TopChapterResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int rank,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String chapterTitle,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int solvedLessonCount,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int ratio
) {
    public static TopChapterResponse of(
            int rank,
            ChapterSolvedStatDto stat,
            long weeklySolvedTotal
    ) {
        int ratio = weeklySolvedTotal == 0
                ? 0
                : Math.toIntExact(stat.solvedLessonCount() * 100 / weeklySolvedTotal);

        return TopChapterResponse.builder()
                .rank(rank)
                .chapterTitle(stat.chapterTitle())
                .solvedLessonCount(Math.toIntExact(stat.solvedLessonCount()))
                .ratio(ratio)
                .build();
    }
}
