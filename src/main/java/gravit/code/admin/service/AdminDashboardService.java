package gravit.code.admin.service;

import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.dto.internal.DailyActiveUserCountDto;
import gravit.code.admin.dto.internal.MonthlyActiveUserCountDto;
import gravit.code.admin.dto.response.DailyActiveUserPointResponse;
import gravit.code.admin.dto.response.DailyActiveUserTrendResponse;
import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.admin.dto.response.MonthlyActiveUserPointResponse;
import gravit.code.admin.dto.response.MonthlyActiveUserTrendResponse;
import gravit.code.admin.repository.AdminActiveUserRepository;
import gravit.code.admin.repository.AdminReportRepository;
import gravit.code.admin.repository.AdminUserRepository;
import gravit.code.admin.repository.StagingLabelRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private static final DateTimeFormatter MONTH_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM");

    private final AdminUserRepository adminUserRepository;
    private final StagingLabelRepository stagingLabelRepository;
    private final AdminReportRepository adminReportRepository;
    private final AdminActiveUserRepository adminActiveUserRepository;

    private final Clock clock;

    @Transactional(readOnly = true)
    public DashboardSummaryResponse getSummary() {
        long totalUsers = adminUserRepository.countActiveUsers();
        long pendingLabelsCount = stagingLabelRepository.countByStatus(LabelStatus.PENDING);
        long unresolvedReportsCount = adminReportRepository.countByIsResolvedFalse();

        return DashboardSummaryResponse.of(totalUsers, pendingLabelsCount, unresolvedReportsCount);
    }

    @Transactional(readOnly = true)
    public DailyActiveUserTrendResponse getDailyActiveUsers(int days) {
        LocalDate endDate = LocalDate.now(clock);
        LocalDate startDate = endDate.minusDays(days - 1L);

        Map<LocalDate, Long> dateToActiveUserCount = adminActiveUserRepository
                .findDailyActiveUserCounts(startDate, endDate).stream()
                .collect(Collectors.toMap(DailyActiveUserCountDto::activityDate, DailyActiveUserCountDto::activeUserCount));

        List<DailyActiveUserPointResponse> points = startDate.datesUntil(endDate.plusDays(1))
                .map(date -> DailyActiveUserPointResponse.of(date, dateToActiveUserCount.getOrDefault(date, 0L)))
                .toList();

        return DailyActiveUserTrendResponse.of(points);
    }

    @Transactional(readOnly = true)
    public MonthlyActiveUserTrendResponse getMonthlyActiveUsers(int months) {
        YearMonth currentMonth = YearMonth.now(clock);
        YearMonth startMonth = currentMonth.minusMonths(months - 1L);

        Map<YearMonth, Long> monthToActiveUserCount = adminActiveUserRepository
                .findMonthlyActiveUserCounts(startMonth.atDay(1), currentMonth.atEndOfMonth()).stream()
                .collect(Collectors.toMap(
                        dto -> YearMonth.of(dto.year(), dto.month()),
                        MonthlyActiveUserCountDto::activeUserCount
                ));

        List<MonthlyActiveUserPointResponse> points = Stream.iterate(startMonth, month -> month.plusMonths(1))
                .limit(months)
                .map(month -> MonthlyActiveUserPointResponse.of(
                        month.format(MONTH_FORMATTER),
                        monthToActiveUserCount.getOrDefault(month, 0L),
                        month.equals(currentMonth)
                ))
                .toList();

        return MonthlyActiveUserTrendResponse.of(points);
    }
}
