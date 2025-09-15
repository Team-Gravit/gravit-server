package gravit.code.mainPage.dto.response;

import gravit.code.mission.domain.MissionType;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "메인페이지 정보 Response")
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
        Integer xp,

        @Schema(
                description = "레벨",
                example = "12"
        )
        Integer level,

        @Schema(
                description = "미션 타입",
                example = "COMPLETE_LESSON_ONE"
        )
        MissionType missionType,

        @Schema(
                description = "행성 정복율",
                example = "70"
        )
        Integer planetConquestRate,

        @Schema(
                description = "연속 학습일",
                example = "10"
        )
        Integer consecutiveDays,

        @Schema(
                description = "챕터 아이디",
                example = "5"
        )
        Long chapterId,

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
        Long totalUnits,

        @Schema(
                description = "완료한 유닛수",
                example = "8"
        )
        Long completedUnits

) {
}
