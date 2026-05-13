package gravit.code.user.dto.response;

import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.league.dto.response.LeagueDetailResponse;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.unit.dto.response.RecommendedUnitResponse;
import lombok.AccessLevel;
import lombok.Builder;

import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record MainPageResponse(
        int profileImgNumber,
        String nickname,
        UserLevelDetailResponse userLevelDetailResponse,
        LeagueDetailResponse leagueDetailResponse,
        LearningDetailResponse learningDetailResponse,
        List<RecommendedUnitResponse> recommendedUnitResponses,
        WeeklyLearningRecordResponse weeklyLearningRecordResponse,
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