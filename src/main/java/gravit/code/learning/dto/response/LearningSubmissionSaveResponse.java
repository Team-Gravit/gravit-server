package gravit.code.learning.dto.response;

import gravit.code.unit.dto.response.UnitSummary;
import gravit.code.user.dto.response.UserLevelResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "풀이 결과 저장 Response")
public record LearningSubmissionSaveResponse(
        @Schema(
                description = "리그 이름",
                example = "브론즈"
        )
        String leagueName,

        @Schema(description = "유저 레벨 정보")
        UserLevelResponse userLevelResponse,

        @Schema(description = "유닛 요약 정보")
        UnitSummary unitSummary
) {
    public static LearningSubmissionSaveResponse create(
            String leagueName,
            UserLevelResponse userLevelResponse,
            UnitSummary unitSummary
    ){
        return LearningSubmissionSaveResponse.builder()
                .leagueName(leagueName)
                .userLevelResponse(userLevelResponse)
                .unitSummary(unitSummary)
                .build();
    }
}