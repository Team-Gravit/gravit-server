package gravit.code.metricReport.dto.internal;

import java.time.LocalDateTime;

public record InquiryItemDto(

        long inquiryId,

        String inquiryType,

        String title,

        LocalDateTime createdAt
) {
}
