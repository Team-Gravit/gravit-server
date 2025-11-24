package gravit.code.learning.dto.common;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@Schema(description = "연속 학습 일수 정보")
public record StreakDto(
        @Schema(
                description = "변경 전 연속 학습 일수",
                example = "5"
        )
        int before,

        @Schema(
                description = "변경 후 연속 학습 일수",
                example = "6"
        )
        int after
) {
    public static StreakDto of(int before, int after) {
        return StreakDto.builder()
                .before(before)
                .after(after)
                .build();
    }
}
