package gravit.code.lesson.dto.response;

import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 결과 화면 Response")
public record LessonResultResponse(

        @Schema(
                description = "리그 이름",
                example = "브론즈",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        String leagueName,

        @Schema(
                description = "유저 레벨 정보",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        UserLevelResponse userLevelResponse,

        @Schema(
                description = "유닛 요약 정보",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        UnitSummaryResponse unitSummaryResponse
) {
    public static LessonResultResponse create(
            String leagueName,
            UserLevelResponse userLevelResponse,
            UnitSummaryResponse unitSummaryResponse
    ){
        return LessonResultResponse.builder()
                .leagueName(leagueName)
                .userLevelResponse(userLevelResponse)
                .unitSummaryResponse(unitSummaryResponse)
                .build();
    }
}
