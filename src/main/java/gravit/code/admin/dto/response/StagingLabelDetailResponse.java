package gravit.code.admin.dto.response;

import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.domain.staging.StagingLabel;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder(access = AccessLevel.PRIVATE)
public record StagingLabelDetailResponse(

        String label,

        long unitId,

        String description,

        LabelStatus status,

        LocalDateTime createdAt,

        StagingLessonResponse lesson,

        List<StagingProblemResponse> problems
) {
    public static StagingLabelDetailResponse of(
            StagingLabel stagingLabel,
            StagingLessonResponse lesson,
            List<StagingProblemResponse> problems
    ) {
        return StagingLabelDetailResponse.builder()
                .label(stagingLabel.getLabel())
                .unitId(stagingLabel.getUnitId())
                .description(stagingLabel.getDescription())
                .status(stagingLabel.getStatus())
                .createdAt(stagingLabel.getCreatedAt())
                .lesson(lesson)
                .problems(problems)
                .build();
    }
}
