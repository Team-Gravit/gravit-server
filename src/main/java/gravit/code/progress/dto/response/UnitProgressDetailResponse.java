package gravit.code.progress.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "유닛 정보 DTO")
public record UnitProgressDetailResponse(
        @Schema(
                description = "유닛 아이디",
                example = "1"
        )
        Long unitId,

        @Schema(
                description = "유닛 이름",
                example = "큐"
        )
        String name,

        @Schema(
                description = "총 레슨",
                example = "3"
        )
        Long totalLesson,

        @Schema(
                description = "푼 레슨",
                example = "2"
        )
        Long completedLesson
) {
        public static UnitProgressDetailResponse create(Long unitId, String name, Long totalLesson, Long completedLesson) {
                return UnitProgressDetailResponse.builder()
                        .unitId(unitId)
                        .name(name)
                        .totalLesson(totalLesson)
                        .completedLesson(completedLesson)
                        .build();
        }
}
