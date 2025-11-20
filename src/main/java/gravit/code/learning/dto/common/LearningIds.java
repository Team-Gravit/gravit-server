package gravit.code.learning.dto.common;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "학습 계층 ID 정보")
public record LearningIds(
        @Schema(
                description = "챕터 아이디",
                example = "1"
        )
        long chapterId,

        @Schema(
                description = "유닛 아이디",
                example = "2"
        )
        long unitId,

        @Schema(
                description = "레슨 아이디",
                example = "3"
        )
        long lessonId
) {
    public static LearningIds of(long chapterId, long unitId, long lessonId) {
        return LearningIds.builder()
                .chapterId(chapterId)
                .unitId(unitId)
                .lessonId(lessonId)
                .build();
    }
}
