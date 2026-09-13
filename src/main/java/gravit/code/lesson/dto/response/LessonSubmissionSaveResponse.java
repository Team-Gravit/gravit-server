package gravit.code.lesson.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "레슨 풀이 결과 저장 Response")
public record LessonSubmissionSaveResponse(

        @Schema(
                description = "생성된 레슨 제출 아이디",
                example = "1",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long lessonSubmissionId,

        @Schema(
                description = "이번 제출의 레슨 XP로 레벨업했는지 여부. 미션 완료 보상 XP로 인한 레벨업은 포함하지 않으며, 재제출은 항상 false",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @JsonProperty("isLevelUp")
        boolean isLevelUp,

        @Schema(
                description = "이번 제출의 리그 점수로 리그가 승급했는지 여부. 리그 점수 지급이 재시도 큐로 넘어갔거나, 승급 여부 조회에 실패했거나, 리그에 참여하지 않았으면 false이며, 재제출은 항상 false",
                example = "false",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @JsonProperty("isLeaguePromoted")
        boolean isLeaguePromoted
) {
    public static LessonSubmissionSaveResponse create(
            long lessonSubmissionId,
            boolean isLevelUp,
            boolean isLeaguePromoted
    ){
        return LessonSubmissionSaveResponse.builder()
                .lessonSubmissionId(lessonSubmissionId)
                .isLevelUp(isLevelUp)
                .isLeaguePromoted(isLeaguePromoted)
                .build();
    }
}
