package gravit.code.mainPage.dto.response;

import gravit.code.recentLearning.dto.response.RecentLearningSummaryResponse;
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
        RecentLearningSummaryResponse recentLearningSummaryResponse
) {
    public static MainPageResponse create(String nickname, Integer level, Integer xp, String league, RecentLearningSummaryResponse recentLearningSummaryResponse){
        return MainPageResponse.builder()
                .nickname(nickname)
                .league(league)
                .level(level)
                .xp(xp)
                .recentLearningSummaryResponse(recentLearningSummaryResponse)
                .build();
    }
}
