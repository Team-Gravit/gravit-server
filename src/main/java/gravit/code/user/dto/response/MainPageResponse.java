package gravit.code.user.dto.response;

import gravit.code.learning.dto.response.LearningDetail;
import gravit.code.mission.dto.response.MissionDetail;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
public record MainPageResponse(
        @Schema(
                description = "닉네임",
                example = "삼준서"
        )
        String nickname,

        @Schema(
                description = "리그 이름(티어)",
                example = "브론즈"
        )
        String leagueName,

        UserLevelDetail userLevelDetail,

        LearningDetail learningDetail,

        MissionDetail missionDetail
) {

        public static MainPageResponse of(
                String nickname,
                String leagueName,
                UserLevelDetail userLevelDetail,
                MissionDetail missionDetail,
                LearningDetail learningDetail
        ) {
                return MainPageResponse.builder()
                        .nickname(nickname)
                        .leagueName(leagueName)
                        .userLevelDetail(userLevelDetail)
                        .missionDetail(missionDetail)
                        .learningDetail(learningDetail)
                        .build();
        }
}