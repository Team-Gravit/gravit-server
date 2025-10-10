package gravit.code.learning.dto.response;

import gravit.code.user.dto.response.UserLevelResponse;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "풀이 결과 저장 Response")
public record LearningResultSaveResponse(

        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        long chapterId,

        @Schema(
                description = "레슨 이름",
                example = "배열 기초"
        )
        String lessonName,

        @Schema(
                description = "리그 이름",
                example = "브론즈 1"
        )
        String leagueName,

        @Schema(
                description = "현재 레벨",
                example = "3"
        )
        int currentLevel,

        @Schema(
                description = "경험치",
                example = "124"
        )
        int xp
) {
    public static  LearningResultSaveResponse create(
            UserLevelResponse userLevelResponse,
            String leagueName,
            long chapterId,
            String lessonName
    ){
        return LearningResultSaveResponse.builder()
                .chapterId(chapterId)
                .lessonName(lessonName)
                .leagueName(leagueName)
                .currentLevel(userLevelResponse.currentLevel())
                .xp(userLevelResponse.xp())
                .build();
    }
}
