package gravit.code.unitProgress.dto.response;

import gravit.code.lessonProgress.dto.response.LessonInfo;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "유닛 페이지 조회 Response")
public record UnitPageResponse(

        @Schema(
                description = "유닛 정보"
        )
        UnitInfo unitInfo,

        @Schema(
                description = "해당 유닛에 포함된 레슨 정보"
        )
        List<LessonInfo> lessonInfos
) {
    public static UnitPageResponse create(UnitInfo unitInfo, List<LessonInfo> lessonInfos) {
        return UnitPageResponse.builder()
                .unitInfo(unitInfo)
                .lessonInfos(lessonInfos)
                .build();
    }
}
