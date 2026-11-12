package gravit.code.admin.dto.response;

import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.domain.staging.StagingLabel;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record StagingLabelListItemResponse(

        String label,

        long unitId,

        String description,

        LabelStatus status,

        LocalDateTime createdAt
) {
    public static StagingLabelListItemResponse from(StagingLabel label) {
        return StagingLabelListItemResponse.builder()
                .label(label.getLabel())
                .unitId(label.getUnitId())
                .description(label.getDescription())
                .status(label.getStatus())
                .createdAt(label.getCreatedAt())
                .build();
    }
}
