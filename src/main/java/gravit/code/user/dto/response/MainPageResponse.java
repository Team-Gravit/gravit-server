package gravit.code.user.dto.response;

import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.league.dto.response.LeagueDetailResponse;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.unit.dto.response.RecommendedUnitResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record MainPageResponse(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        int profileImgNumber,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        String nickname,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        UserLevelDetailResponse userLevelDetailResponse,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LeagueDetailResponse leagueDetailResponse,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        LearningDetailResponse learningDetailResponse,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        List<RecommendedUnitResponse> recommendedUnitResponses,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        WeeklyLearningRecordResponse weeklyLearningRecordResponse,

        @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
        MissionDetailResponse missionDetailResponse
) {
    public static MainPageResponse of(
            int profileImgNumber,
            String nickname,
            UserLevelDetailResponse userLevelDetailResponse,
            LeagueDetailResponse leagueDetailResponse,
            LearningDetailResponse learningDetailResponse,
            List<RecommendedUnitResponse> recommendedUnitResponses,
            WeeklyLearningRecordResponse weeklyLearningRecordResponse,
            MissionDetailResponse missionDetailResponse
    ) {
        return MainPageResponse.builder()
                .profileImgNumber(profileImgNumber)
                .nickname(nickname)
                .userLevelDetailResponse(userLevelDetailResponse)
                .leagueDetailResponse(leagueDetailResponse)
                .learningDetailResponse(learningDetailResponse)
                .recommendedUnitResponses(recommendedUnitResponses)
                .weeklyLearningRecordResponse(weeklyLearningRecordResponse)
                .missionDetailResponse(missionDetailResponse)
                .build();
    }
}