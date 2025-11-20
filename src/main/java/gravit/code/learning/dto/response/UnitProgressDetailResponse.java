package gravit.code.learning.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "유닛 정보 DTO")
public record UnitProgressDetailResponse(
        @Schema(
                description = "유닛 아이디",
                example = "1"
        )
        long unitId,

        @Schema(
                description = "유닛 이름",
                example = "큐"
        )
        String name,

        @Schema(
                description = "총 레슨",
                example = "3"
        )
        long totalLesson,

        @Schema(
                description = "푼 레슨",
                example = "2"
        )
        long completedLesson
) {
        public static UnitProgressDetailResponse create(
                long unitId,
                String name,
                long totalLesson,
                long completedLesson
        ) {
                return UnitProgressDetailResponse.builder()
                        .unitId(unitId)
                        .name(name)
                        .totalLesson(totalLesson)
                        .completedLesson(completedLesson)
                        .build();
        }
}
