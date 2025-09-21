package gravit.code.mainPage.dto.response;

import gravit.code.mainPage.dto.MainPageSummary;
import gravit.code.mission.dto.MissionSummary;
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

        @Schema(
                description = "경험치",
                example = "789"
        )
        int xp,

        @Schema(
                description = "레벨",
                example = "12"
        )
        int level,

        @Schema(
                description = "행성 정복율",
                example = "70"
        )
        int planetConquestRate,

        @Schema(
                description = "연속 학습일",
                example = "10"
        )
        int consecutiveDays,

        @Schema(
                description = "챕터 아이디",
                example = "5"
        )
        long chapterId,

        @Schema(
                description = "챕터 이름",
                example = "자료구조"
        )
        String chapterName,

        @Schema(
                description = "챕터 설명",
                example = "스택, 큐, 힙과 같은 자료구조에 대해 학습합니다."
        )
        String chapterDescription,

        @Schema(
                description = "총 유닛수",
                example = "10"
        )
        long totalUnits,

        @Schema(
                description = "완료한 유닛수",
                example = "8"
        )
        long completedUnits,

        @Schema(
                description = "미션 이름",
                example = "레슨 1개 완료하기"
        )
        String missionName,

        @Schema(
                description = "보상 xp",
                example = "40"
        )
        int awardXp,

        @Schema(
                description = "완료 여부",
                example = "false"
        )
        boolean isCompleted
) {

    public static MainPageResponse create(MainPageSummary mainPageSummary, MissionSummary missionSummary) {
        return MainPageResponse.builder()
                .nickname(mainPageSummary.nickname())
                .leagueName(mainPageSummary.leagueName())
                .xp(mainPageSummary.xp())
                .level(mainPageSummary.level())
                .planetConquestRate(mainPageSummary.planetConquestRate())
                .consecutiveDays(mainPageSummary.consecutiveDays())
                .chapterId(mainPageSummary.chapterId())
                .chapterName(mainPageSummary.chapterName())
                .chapterDescription(mainPageSummary.chapterDescription())
                .totalUnits(mainPageSummary.totalUnits())
                .completedUnits(mainPageSummary.completedUnits())
                .missionName(missionSummary.missionType().getDescription())
                .awardXp(missionSummary.missionType().getAwardXp())
                .isCompleted(missionSummary.isCompleted())
                .build();
    }
}
