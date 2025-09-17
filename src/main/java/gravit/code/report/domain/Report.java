package gravit.code.report.domain;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.ZoneId;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Report {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "report_type", nullable = false)
    private ReportType reportType;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "problem_id", columnDefinition = "bigint", nullable = false)
    private Long problemId;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "is_resolved", columnDefinition = "boolean", nullable = false)
    private Boolean isResolved;

    @Column(name = "submitted_at", columnDefinition = "timestamp", nullable = false)
    private LocalDateTime submittedAt;

    @Builder
    private Report(ReportType reportType, String content, Long problemId, Long userId) {
        this.reportType = reportType;
        this.content = content;
        this.problemId = problemId;
        this.userId = userId;
        this.isResolved = false;
        this.submittedAt = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
    }

    public static Report create(ReportType reportType, String content, Long problemId, Long userId){
        return Report.builder()
                .reportType(reportType)
                .content(content)
                .problemId(problemId)
                .userId(userId)
                .build();
    }

    public void updateResolvedStatus(){
        this.isResolved = !this.isResolved;
    }
}
