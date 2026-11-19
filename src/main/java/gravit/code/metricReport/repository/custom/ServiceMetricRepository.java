package gravit.code.metricReport.repository.custom;

import gravit.code.metricReport.dto.internal.InquiryItemDto;
import gravit.code.metricReport.dto.internal.InterviewMetricDto;
import gravit.code.metricReport.dto.internal.LessonMetricDto;
import gravit.code.metricReport.dto.internal.ReportItemDto;
import gravit.code.metricReport.dto.internal.RetentionDto;
import gravit.code.metricReport.dto.internal.TypeCountDto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface ServiceMetricRepository {

    long countSignups(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    );

    long countDailyActivities(
            LocalDate startDate,
            LocalDate endDate
    );

    long countDistinctActiveUsers(
            LocalDate startDate,
            LocalDate endDate
    );

    RetentionDto findRetention(
            LocalDate cohortStartDate,
            LocalDate cohortEndDate,
            int dayOffset
    );

    LessonMetricDto findLessonMetric(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    );

    InterviewMetricDto findInterviewMetric(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    );

    List<TypeCountDto> countReportsByType(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    );

    List<ReportItemDto> findReports(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt,
            int limit
    );

    List<TypeCountDto> countInquiriesByType(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt
    );

    long countPendingInquiries();

    List<InquiryItemDto> findInquiries(
            LocalDateTime startAt,
            LocalDateTime endExclusiveAt,
            int limit
    );
}
