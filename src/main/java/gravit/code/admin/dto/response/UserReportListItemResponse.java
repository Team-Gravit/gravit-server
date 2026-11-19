package gravit.code.admin.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import gravit.code.report.domain.UserReport;
import gravit.code.report.domain.UserReportType;
import lombok.AccessLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder(access = AccessLevel.PRIVATE)
public record UserReportListItemResponse(

        long reportId,

        long reporterId,

        long targetUserId,

        UserReportType reportType,

        String reportedNickname,

        String content,

        @JsonProperty("isResolved")
        boolean isResolved,

        LocalDateTime submittedAt
) {
    public static UserReportListItemResponse from(UserReport userReport) {
        return UserReportListItemResponse.builder()
                .reportId(userReport.getId())
                .reporterId(userReport.getReporterId())
                .targetUserId(userReport.getTargetUserId())
                .reportType(userReport.getReportType())
                .reportedNickname(userReport.getReportedNickname())
                .content(userReport.getContent())
                .isResolved(userReport.isResolved())
                .submittedAt(userReport.getSubmittedAt())
                .build();
    }
}
