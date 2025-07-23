package gravit.code.domain.mainPage.dto.response;

import gravit.code.domain.learning.dto.response.RecentLearningInfo;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "메인페이지 정보 Response")
public record MainPageResponse(
        @Schema(
                description = "유저 닉네임",
                example = "땅콩"
        )
        String nickname,

        @Schema(
                description = "유저 레벨",
                example = "4"
        )
        Integer level,

        @Schema(
                description = "유저 경험치",
                example = "100"
        )
        Integer xp,

        @Schema(
                description = "유저 리그",
                example = "브론즈"
        )
        String league,

        @Schema(
                description = "최근학습정보",
                example = ""
        )
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
