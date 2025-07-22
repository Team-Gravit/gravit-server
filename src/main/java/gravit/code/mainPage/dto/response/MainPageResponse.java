package gravit.code.mainPage.dto.response;

import gravit.code.learning.dto.response.RecentLearningInfo;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "메인페이지 정보 Response")
public record MainPageResponse(
        String nickname,
        Integer level,
        Integer xp,
        String league,
        RecentLearningInfo recentLearningInfo
) {
    public static MainPageResponse create(String nickname, Integer level, Integer xp, String league, RecentLearningInfo recentLearningInfo){
        return MainPageResponse.builder()
                .nickname(nickname)
                .league(league)
                .level(level)
                .xp(xp)
                .recentLearningInfo(recentLearningInfo)
                .build();
    }
}
