package gravit.code.admin.service;

import gravit.code.admin.dto.response.DailyActiveUserPointResponse;
import gravit.code.admin.dto.response.DailyActiveUserTrendResponse;
import gravit.code.admin.dto.response.DashboardSummaryResponse;
import gravit.code.admin.dto.response.MonthlyActiveUserPointResponse;
import gravit.code.admin.dto.response.MonthlyActiveUserTrendResponse;
import gravit.code.admin.fixture.StagingFixture;
import gravit.code.admin.repository.StagingLabelRepository;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import gravit.code.report.repository.ReportRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.fixture.UserDailyActivityFixture;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.service.UserAccessService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

// 고정 시계 기준 now = 2025-08-05T12:00 (Asia/Seoul)
@TCSpringBootTest
class AdminDashboardServiceIntegrationTest {

    private static final long ADMIN_ID = 1L;
    private static final LocalDate TODAY = LocalDate.of(2025, 8, 5);

    @Autowired
    private AdminDashboardService adminDashboardService;

    @Autowired
    private AdminUserService adminUserService;

    @Autowired
    private UserAccessService userAccessService;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private UserDailyActivityFixture userDailyActivityFixture;

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

    @Nested
    @DisplayName("일별 활성 유저 추이를 조회할 때")
    class GetDailyActiveUsers {

        @Test
        void 요청_일수만큼_연속된_포인트를_오래된_날짜부터_돌려주고_활동이_없는_날은_0이다() {
            // given (days=7 → 07-30 ~ 08-05)
            User user1 = userFixture.일반_유저(1);
            User user2 = userFixture.일반_유저(2);
            userDailyActivityFixture.활동_이력(user1.getId(), LocalDate.of(2025, 7, 30), LocalDate.of(2025, 8, 2), TODAY);
            userDailyActivityFixture.활동_이력(user2.getId(), LocalDate.of(2025, 8, 2));

            // when
            DailyActiveUserTrendResponse response = adminDashboardService.getDailyActiveUsers(7);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.points()).hasSize(7);
                softly.assertThat(response.points()).extracting(DailyActiveUserPointResponse::date).containsExactly(
                        LocalDate.of(2025, 7, 30), LocalDate.of(2025, 7, 31), LocalDate.of(2025, 8, 1),
                        LocalDate.of(2025, 8, 2), LocalDate.of(2025, 8, 3), LocalDate.of(2025, 8, 4), TODAY
                );
                softly.assertThat(response.points()).extracting(DailyActiveUserPointResponse::dau)
                        .containsExactly(1L, 0L, 0L, 2L, 0L, 0L, 1L);
            });
        }

        @Test
        void 조회_구간_시작일_활동은_포함하고_그_전날_활동은_제외한다() {
            // given (days=3 → 08-03 ~ 08-05)
            User user = userFixture.일반_유저(1);
            userDailyActivityFixture.활동_이력(user.getId(), LocalDate.of(2025, 8, 2), LocalDate.of(2025, 8, 3));

            // when
            DailyActiveUserTrendResponse response = adminDashboardService.getDailyActiveUsers(3);

            // then
            assertThat(response.points()).extracting(DailyActiveUserPointResponse::dau).containsExactly(1L, 0L, 0L);
        }

        @Test
        void 같은_유저가_같은_날_여러_번_접속해도_한_명으로_센다() {
            // given
            User user = userFixture.일반_유저(1);
            userAccessService.updateLastAccessed(user.getId());
            userAccessService.updateLastAccessed(user.getId());

            // when
            DailyActiveUserTrendResponse response = adminDashboardService.getDailyActiveUsers(1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.points()).hasSize(1);
                softly.assertThat(response.points().get(0).date()).isEqualTo(TODAY);
                softly.assertThat(response.points().get(0).dau()).isEqualTo(1L);
            });
        }

        @Test
        void 활동_이력이_전혀_없으면_모든_포인트가_0이다() {
            // when
            DailyActiveUserTrendResponse response = adminDashboardService.getDailyActiveUsers(5);

            // then
            assertThat(response.points())
                    .hasSize(5)
                    .allSatisfy(point -> assertThat(point.dau()).isZero());
        }
    }

    @Nested
    @DisplayName("월별 활성 유저 추이를 조회할 때")
    class GetMonthlyActiveUsers {

        @Test
        void 요청_개월_수만큼_연속된_포인트를_오래된_달부터_돌려주고_활동이_없는_달은_0이다() {
            // given (months=3 → 2025-06, 2025-07, 2025-08)
            User user1 = userFixture.일반_유저(1);
            User user2 = userFixture.일반_유저(2);
            userDailyActivityFixture.활동_이력(user1.getId(), LocalDate.of(2025, 7, 1), LocalDate.of(2025, 7, 15), TODAY);
            userDailyActivityFixture.활동_이력(user2.getId(), LocalDate.of(2025, 7, 20));

            // when
            MonthlyActiveUserTrendResponse response = adminDashboardService.getMonthlyActiveUsers(3);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.points()).hasSize(3);
                softly.assertThat(response.points()).extracting(MonthlyActiveUserPointResponse::month)
                        .containsExactly("2025-06", "2025-07", "2025-08");
                softly.assertThat(response.points()).extracting(MonthlyActiveUserPointResponse::mau)
                        .containsExactly(0L, 2L, 1L);
            });
        }

        @Test
        void 한_유저가_한_달에_여러_날_활동해도_그_달에_한_명으로_센다() {
            // given
            User user = userFixture.일반_유저(1);
            userDailyActivityFixture.활동_이력(user.getId(),
                    LocalDate.of(2025, 7, 1), LocalDate.of(2025, 7, 2), LocalDate.of(2025, 7, 31));

            // when
            MonthlyActiveUserTrendResponse response = adminDashboardService.getMonthlyActiveUsers(2);

            // then
            assertThat(response.points()).extracting(MonthlyActiveUserPointResponse::mau).containsExactly(1L, 0L);
        }

        @Test
        void 이번_달만_진행_중으로_표시한다() {
            // when
            MonthlyActiveUserTrendResponse response = adminDashboardService.getMonthlyActiveUsers(3);

            // then
            assertThat(response.points()).extracting(MonthlyActiveUserPointResponse::inProgress)
                    .containsExactly(false, false, true);
        }

        @Test
        void 조회_구간_시작_달의_첫날_활동은_포함하고_그_전날_활동은_제외한다() {
            // given (months=3 → 06-01 포함, 05-31 제외)
            User user1 = userFixture.일반_유저(1);
            User user2 = userFixture.일반_유저(2);
            userDailyActivityFixture.활동_이력(user1.getId(), LocalDate.of(2025, 5, 31));
            userDailyActivityFixture.활동_이력(user2.getId(), LocalDate.of(2025, 6, 1));

            // when
            MonthlyActiveUserTrendResponse response = adminDashboardService.getMonthlyActiveUsers(3);

            // then
            assertThat(response.points()).extracting(MonthlyActiveUserPointResponse::mau).containsExactly(1L, 0L, 0L);
        }
    }
}
