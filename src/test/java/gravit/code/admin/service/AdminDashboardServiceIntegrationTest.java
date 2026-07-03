package gravit.code.admin.service;

import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.admin.fixture.StagingFixture;
import gravit.code.admin.repository.StagingLabelRepository;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import gravit.code.report.repository.ReportRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.fixture.UserFixture;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminDashboardServiceIntegrationTest {

    private static final long ADMIN_ID = 1L;

    @Autowired
    private AdminDashboardService adminDashboardService;

    @Autowired
    private AdminUserService adminUserService;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private StagingLabelRepository stagingLabelRepository;

    @Autowired
    private ReportRepository reportRepository;

    private void saveReport(
            ReportType type,
            long problemId,
            boolean resolved
    ) {
        Report report = Report.of(type, "내용", problemId, 100L);
        if (resolved) {
            report.changeResolved(true);
        }
        reportRepository.save(report);
    }

    @Test
    @DisplayName("대시보드 요약: totalUsers(DELETED 제외)·pendingLabels·unresolvedReports 집계")
    void getSummary() {
        // users: 2 active + 1 suspended + 1 deleted -> totalUsers = 3
        userFixture.일반_유저(1);
        userFixture.일반_유저(2);
        User suspended = userFixture.일반_유저(3);
        User deleted = userFixture.일반_유저(4);
        adminUserService.updateStatus(ADMIN_ID, suspended.getId(), UserStatus.SUSPENDED);
        adminUserService.updateStatus(ADMIN_ID, deleted.getId(), UserStatus.DELETED);

        // staging labels: 2 pending + 1 completed -> pending = 2
        stagingLabelRepository.save(StagingFixture.라벨(1L, "2026-01-01-aaaa", 1L));
        stagingLabelRepository.save(StagingFixture.라벨(2L, "2026-01-01-bbbb", 1L));
        var completed = StagingFixture.라벨(3L, "2026-01-01-cccc", 1L);
        completed.complete();
        stagingLabelRepository.save(completed);

        // reports: 2 unresolved + 1 resolved -> unresolved = 2
        saveReport(ReportType.TYPO_ERROR, 10L, false);
        saveReport(ReportType.CONTENT_ERROR, 11L, false);
        saveReport(ReportType.ANSWER_ERROR, 12L, true);

        DashboardSummaryResponse summary = adminDashboardService.getSummary();

        assertSoftly(softly -> {
            softly.assertThat(summary.totalUsers()).isEqualTo(3);
            softly.assertThat(summary.pendingLabelsCount()).isEqualTo(2);
            softly.assertThat(summary.unresolvedReportsCount()).isEqualTo(2);
        });
    }
}
