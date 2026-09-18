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
        UnitSummaryResponse unitSummaryResponse,

        @Schema(
                description = "정답률(단위 : 정수, 0~100)",
                example = "79",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int accuracy,

        @Schema(
                description = "풀이 시간(단위 : 정수 초) / 1분 20초가 걸렸다면 80",
                example = "80",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        int learningTime
) {
    public static LessonResultResponse create(
            String leagueName,
            UserLevelResponse userLevelResponse,
            UnitSummaryResponse unitSummaryResponse,
            int accuracy,
            int learningTime
    ){
        return LessonResultResponse.builder()
                .leagueName(leagueName)
                .userLevelResponse(userLevelResponse)
                .unitSummaryResponse(unitSummaryResponse)
                .accuracy(accuracy)
                .learningTime(learningTime)
                .build();
    }
}
