package gravit.code.admin.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDate;

@Builder(access = AccessLevel.PRIVATE)
public record DailyActiveUserPointResponse(

        @Schema(
                description = "날짜",
                example = "2026-09-05",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        LocalDate date,

        @Schema(
                description = "해당 날짜의 활성 유저 수",
                example = "42",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        long dau
) {
    public static DailyActiveUserPointResponse of(
            LocalDate date,
            long dau
    ) {
        return DailyActiveUserPointResponse.builder()
                .date(date)
                .dau(dau)
                .build();
    }
}
