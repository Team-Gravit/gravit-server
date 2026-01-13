package gravit.code.lesson.dto.response;

import gravit.code.unit.dto.response.UnitSummary;
import gravit.code.user.dto.response.UserLevelResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "풀이 결과 저장 Response")
public record LessonSubmissionSaveResponse(

        @Schema(
                description = "리그 이름",
                example = "브론즈"
        )
        @NotNull
        String leagueName,

        @Schema(description = "유저 레벨 정보")
        @NotNull
        UserLevelResponse userLevelResponse,

        @Schema(description = "유닛 요약 정보")
        @NotNull
        UnitSummary unitSummary
) {
    public static LessonSubmissionSaveResponse create(
            String leagueName,
            UserLevelResponse userLevelResponse,
            UnitSummary unitSummary
    ){
        return LessonSubmissionSaveResponse.builder()
                .leagueName(leagueName)
                .userLevelResponse(userLevelResponse)
                .unitSummary(unitSummary)
                .build();
    }
}