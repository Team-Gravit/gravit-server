package gravit.code.report.domain;

import gravit.code.global.consts.TimeZoneConst;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_SELF_NOT_ALLOWED;

@Table(name = "user_report")
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "reporter_id", nullable = false)
    private long reporterId;

    @Column(name = "target_user_id", nullable = false)
    private long targetUserId;

    @Enumerated(EnumType.STRING)
    @Column(name = "report_type", nullable = false)
    private UserReportType reportType;

    @Column(name = "reported_nickname", nullable = false)
    private String reportedNickname;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "is_resolved", nullable = false)
    private boolean isResolved;

    @Column(name = "submitted_at", nullable = false)
    private LocalDateTime submittedAt;

    @Builder(access = AccessLevel.PRIVATE)
    private UserReport(
            long reporterId,
            long targetUserId,
            UserReportType reportType,
            String reportedNickname,
            String content
    ) {
        this.reporterId = reporterId;
        this.targetUserId = targetUserId;
        this.reportType = reportType;
        this.reportedNickname = reportedNickname;
        this.content = content;
        this.isResolved = false;
        this.submittedAt = LocalDateTime.now(TimeZoneConst.KST);
    }

    public static UserReport create(
            long reporterId,
            long targetUserId,
            UserReportType reportType,
            String reportedNickname,
            String content
    ) {
        validateNotSelf(reporterId, targetUserId);

        return UserReport.builder()
                .reporterId(reporterId)
                .targetUserId(targetUserId)
                .reportType(reportType)
                .reportedNickname(reportedNickname)
                .content(content)
                .build();
    }

    private static void validateNotSelf(
            long reporterId,
            long targetUserId
    ) {
        if (reporterId == targetUserId) {
            throw new RestApiException(USER_REPORT_SELF_NOT_ALLOWED);
        }
    }

    public void changeResolved(boolean isResolved) {
        this.isResolved = isResolved;
    }
}
