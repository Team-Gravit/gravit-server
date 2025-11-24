package gravit.code.chapter.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "챕터 정보 조회 Response")
public record ChapterDetailResponse(

        @Schema(description = "챕터 요약 정보")
        ChapterSummary chapterSummary,

        @Schema(
                description = "진행도(퍼센트)",
                example = "12.3"
        )
        double chapterProgressRate
) {
    public static ChapterDetailResponse create(
            ChapterSummary chapterSummary,
            double chapterProgressRate
    ) {
        return ChapterDetailResponse.builder()
                .chapterSummary(chapterSummary)
                .chapterProgressRate(chapterProgressRate)
                .build();
    }
}
