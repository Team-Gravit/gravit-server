package gravit.code.dailyLearningRecord.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.dailyLearningRecord.domain.DayTiming;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
public record DayLearningRecordResponse(
        @Schema(
                description = "서버 기준(KST) 오늘과 비교한 요일 시점. PAST: 지난 요일, TODAY: 오늘, FUTURE: 오늘 이후 요일",
                example = "TODAY",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        DayTiming dayTiming,

        @Schema(
                description = "그날 학습 완료 여부. FUTURE 요일은 항상 false",
                example = "true",
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @JsonProperty("isCompleted")
        boolean isCompleted
) {
    public static DayLearningRecordResponse of(
            DayTiming dayTiming,
            boolean isCompleted
    ) {
        return DayLearningRecordResponse.builder()
                .dayTiming(dayTiming)
                .isCompleted(isCompleted)
                .build();
    }
}
