package gravit.code.learning.dto.response;

import gravit.code.learning.domain.Chapter;
import gravit.code.progress.dto.response.UnitDetail;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "유닛 페이지 조회 Response")
public record UnitPageResponse(
        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        long chapterId,

        @Schema(
                description = "챕터 이름",
                example = "자료구조"
        )
        String chapterName,

        @Schema(
                description = "챕터 설명",
                example = "자료구조 챕터 설명"
        )
        String chapterDescription,

        List<UnitDetail> unitDetails
) {

    public static UnitPageResponse create(Chapter chapter, List<UnitDetail> unitDetails) {
        return UnitPageResponse.builder()
                .chapterId(chapter.getId())
                .chapterName(chapter.getName())
                .chapterDescription(chapter.getDescription())
                .unitDetails(unitDetails)
                .build();
    }
}
