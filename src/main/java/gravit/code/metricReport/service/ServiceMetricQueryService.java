package gravit.code.metricReport.service;

import gravit.code.admin.repository.AdminReportRepository;
import gravit.code.admin.repository.AdminUserRepository;
import gravit.code.metricReport.config.DiscordProps;
import gravit.code.metricReport.domain.MetricPeriod;
import gravit.code.metricReport.dto.internal.InterviewMetricDto;
import gravit.code.metricReport.dto.internal.LessonMetricDto;
import gravit.code.metricReport.dto.internal.MetricRangeDto;
import gravit.code.metricReport.dto.internal.ReportInquiryMetricDto;
import gravit.code.metricReport.dto.internal.RetentionDto;
import gravit.code.metricReport.dto.internal.ServiceMetricReportDto;
import gravit.code.metricReport.dto.internal.ServiceMetricSnapshotDto;
import gravit.code.metricReport.dto.internal.UserMetricDto;
import gravit.code.metricReport.repository.custom.ServiceMetricRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;

@Service
@RequiredArgsConstructor
public class ServiceMetricQueryService {

    private static final int D1_DAY_OFFSET = 1;
    private static final int D7_DAY_OFFSET = 7;

    private final ServiceMetricRepository serviceMetricRepository;
    private final AdminUserRepository adminUserRepository;
    private final AdminReportRepository adminReportRepository;

    private final Clock clock;
    private final DiscordProps discordProps;

    @Transactional(readOnly = true)
    public ServiceMetricReportDto getReport(MetricPeriod period) {
        LocalDateTime now = LocalDateTime.now(clock);
        LocalDate today = now.toLocalDate();
        MetricRangeDto range = period.toRange(today);

        ServiceMetricSnapshotDto current = getSnapshot(range, today);

        ServiceMetricSnapshotDto previous = period.toPreviousRange(today)
                .map(previousRange -> getSnapshot(previousRange, today))
                .orElse(null);

        ReportInquiryMetricDto reportsAndInquiries = getReportsAndInquiries(range);

        return ServiceMetricReportDto.of(
                period,
                current,
                previous,
                reportsAndInquiries,
                now
        );
    }

    private ServiceMetricSnapshotDto getSnapshot(
            MetricRangeDto range,
            LocalDate today
    ) {
        UserMetricDto users = getUserMetric(range, today);

        LessonMetricDto lessons = serviceMetricRepository.findLessonMetric(range.startAt(), range.endExclusiveAt());

        InterviewMetricDto interviews = serviceMetricRepository.findInterviewMetric(range.startAt(), range.endExclusiveAt());

        return ServiceMetricSnapshotDto.of(range, users, lessons, interviews);
    }

    private UserMetricDto getUserMetric(
            MetricRangeDto range,
            LocalDate today
    ) {
        long totalUsers = adminUserRepository.countActiveUsers();
        long newSignups = serviceMetricRepository.countSignups(range.startAt(), range.endExclusiveAt());

        long dailyActivities = serviceMetricRepository.countDailyActivities(range.startDate(), range.endDate());
        double averageDailyActiveUsers = (double) dailyActivities / range.days();
        long activeUsers = serviceMetricRepository.countDistinctActiveUsers(range.startDate(), range.endDate());

        LocalDate mauEndDate = range.endDate();
        YearMonth mauMonth = YearMonth.from(mauEndDate);
        long monthlyActiveUsers = serviceMetricRepository.countDistinctActiveUsers(mauMonth.atDay(1), mauEndDate);
        boolean mauInProgress = !mauEndDate.equals(mauMonth.atEndOfMonth()) || mauEndDate.equals(today);

        RetentionDto d1Retention = getRetention(range, D1_DAY_OFFSET);
        RetentionDto d7Retention = getRetention(range, D7_DAY_OFFSET);

        return UserMetricDto.of(
                totalUsers,
                newSignups,
                averageDailyActiveUsers,
                activeUsers,
                monthlyActiveUsers,
                mauMonth,
                mauInProgress,
                d1Retention,
                d7Retention
        );
    }

    private RetentionDto getRetention(
            MetricRangeDto range,
            int dayOffset
    ) {
        MetricRangeDto cohortRange = range.minusDays(dayOffset);

        return serviceMetricRepository.findRetention(cohortRange.startDate(), cohortRange.endDate(), dayOffset);
    }

    private ReportInquiryMetricDto getReportsAndInquiries(MetricRangeDto range) {
        int listLimit = discordProps.listLimit();

        return ReportInquiryMetricDto.of(
                serviceMetricRepository.countReportsByType(range.startAt(), range.endExclusiveAt()),
                adminReportRepository.countByIsResolvedFalse(),
                serviceMetricRepository.findReports(range.startAt(), range.endExclusiveAt(), listLimit),
                serviceMetricRepository.countInquiriesByType(range.startAt(), range.endExclusiveAt()),
                serviceMetricRepository.countPendingInquiries(),
                serviceMetricRepository.findInquiries(range.startAt(), range.endExclusiveAt(), listLimit)
        );
    }
}
