package gravit.code.metricReport.dto.internal;

import java.time.LocalDateTime;

public record ReportItemDto(

        long reportId,

        String reportType,

        long problemId,

        LocalDateTime submittedAt
) {
}
