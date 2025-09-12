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

    @Column(columnDefinition = "TEXT")
    private String content;

    @Column(name = "chapter_id", columnDefinition = "bigint", nullable = false)
    private Long chapterId;

    @Column(name = "unit_id", columnDefinition = "bigint", nullable = false)
    private Long unitId;

    @Column(name = "lesson_id", columnDefinition = "bigint", nullable = false)
    private Long lessonId;

    @Column(name = "user_id", columnDefinition = "bigint", nullable = false)
    private Long userId;

    @Column(name = "is_resolved", columnDefinition = "boolean", nullable = false)
    private Boolean isResolved;

    @Column(name = "submitted_at", columnDefinition = "timestamp", nullable = false)
    private LocalDateTime submittedAt;

    @Builder
    private Report(ReportType reportType, String content, Long chapterId, Long unitId, Long lessonId, Long userId) {
        this.reportType = reportType;
        this.content = content;
        this.chapterId = chapterId;
        this.unitId = unitId;
        this.lessonId = lessonId;
        this.userId = userId;
        this.isResolved = false;
        this.submittedAt = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
    }

    public static Report create(ReportType reportType, String content, Long chapterId, Long unitId, Long lessonId, Long userId){
        return Report.builder()
                .reportType(reportType)
                .content(content)
                .chapterId(chapterId)
                .unitId(unitId)
                .lessonId(lessonId)
                .userId(userId)
                .build();
    }
}
