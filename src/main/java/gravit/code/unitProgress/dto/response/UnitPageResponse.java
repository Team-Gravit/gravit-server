package gravit.code.unitProgress.dto.response;

import gravit.code.lessonProgress.dto.response.LessonInfo;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

import java.util.List;

@Builder
@Schema(description = "유닛 페이지 조회 Response")
public record UnitPageResponse(
        UnitInfo unitInfo,
        List<LessonInfo> lessonInfos
) {
    public static UnitPageResponse create(UnitInfo unitInfo, List<LessonInfo> lessonInfos) {
        return UnitPageResponse.builder()
                .unitInfo(unitInfo)
                .lessonInfos(lessonInfos)
                .build();
    }
}
