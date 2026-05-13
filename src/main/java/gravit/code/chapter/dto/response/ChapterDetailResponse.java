package gravit.code.chapter.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "챕터 정보 조회 Response")
public record ChapterDetailResponse(

        @Schema(description = "챕터 요약 정보")
        @NotNull
        ChapterSummaryResponse chapterSummaryResponse,

        @Schema(
                description = "진행도(퍼센트)",
                example = "12.3"
        )
        double chapterProgressRate
) {
    public static ChapterDetailResponse create(
            ChapterSummaryResponse chapterSummaryResponse,
            double chapterProgressRate
    ) {
        return ChapterDetailResponse.builder()
                .chapterSummaryResponse(chapterSummaryResponse)
                .chapterProgressRate(chapterProgressRate)
                .build();
    }
}
