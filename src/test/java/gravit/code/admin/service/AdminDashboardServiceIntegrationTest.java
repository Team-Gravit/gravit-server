package gravit.code.admin.service;

import gravit.code.admin.dto.response.AdminDashboardSummaryResponse;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportType;
import gravit.code.report.repository.ReportRepository;
import gravit.code.stagingLabel.domain.LabelStatus;
import gravit.code.stagingLabel.domain.StagingLabel;
import gravit.code.stagingLabel.repository.StagingLabelRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.Role;
import gravit.code.user.fixture.UserFixtureBuilder;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Constructor;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@Transactional
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class AdminDashboardServiceIntegrationTest {

    @Autowired
    private AdminDashboardService adminDashboardService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StagingLabelRepository stagingLabelRepository;

    @Autowired
    private ReportRepository reportRepository;

    private void saveUser(
            String email,
            String providerId,
            String nickname,
            String handle
    ) {
        userRepository.save(UserFixtureBuilder.유저(email, providerId, nickname, handle, Role.USER));
    }

    private void saveStagingLabel(
            long id,
            String label,
            LabelStatus status
    ) {
        try {
            Constructor<StagingLabel> ctor = StagingLabel.class.getDeclaredConstructor();
            ctor.setAccessible(true);
            StagingLabel stagingLabel = ctor.newInstance();
            ReflectionTestUtils.setField(stagingLabel, "id", id);
            ReflectionTestUtils.setField(stagingLabel, "label", label);
            ReflectionTestUtils.setField(stagingLabel, "unitId", 1L);
            ReflectionTestUtils.setField(stagingLabel, "description", "라벨 설명");
            ReflectionTestUtils.setField(stagingLabel, "labelStatus", status);
            ReflectionTestUtils.setField(stagingLabel, "createdAt", LocalDateTime.now());
            stagingLabelRepository.save(stagingLabel);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    private void saveReport(
            long problemId,
            long userId,
            boolean resolved
    ) {
        Report report = Report.builder()
                .reportType(ReportType.CONTENT_ERROR)
                .content("신고 내용")
                .problemId(problemId)
                .userId(userId)
                .build();
        if (resolved) {
            report.updateResolvedStatus();
        }
        reportRepository.save(report);
    }

    @Nested
    @DisplayName("백오피스 대시보드 요약을 조회할 때")
    class GetDashboardSummary {

        @Test
        void 데이터가_없으면_모두_0을_반환한다() {
            // when
            AdminDashboardSummaryResponse result = adminDashboardService.getDashboardSummary();

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.totalUsers()).isZero();
                softly.assertThat(result.pendingLabelsCount()).isZero();
                softly.assertThat(result.unresolvedReportsCount()).isZero();
            });
        }

        @Test
        void 전체_유저_수를_반환한다() {
            // given
            saveUser("a@test.com", "provider_a", "유저A", "handleA");
            saveUser("b@test.com", "provider_b", "유저B", "handleB");
            saveUser("c@test.com", "provider_c", "유저C", "handleC");

            // when
            AdminDashboardSummaryResponse result = adminDashboardService.getDashboardSummary();

            // then
            assertThat(result.totalUsers()).isEqualTo(3);
        }

        @Test
        void PENDING_상태의_라벨_수만_집계한다() {
            // given
            saveStagingLabel(1L, "label_1", LabelStatus.PENDING);
            saveStagingLabel(2L, "label_2", LabelStatus.PENDING);
            saveStagingLabel(3L, "label_3", LabelStatus.COMPLETED);

            // when
            AdminDashboardSummaryResponse result = adminDashboardService.getDashboardSummary();

            // then
            assertThat(result.pendingLabelsCount()).isEqualTo(2);
        }

        @Test
        void 미해결_상태의_신고_수만_집계한다() {
            // given
            saveReport(1L, 100L, false);
            saveReport(2L, 100L, false);
            saveReport(3L, 100L, true);

            // when
            AdminDashboardSummaryResponse result = adminDashboardService.getDashboardSummary();

            // then
            assertThat(result.unresolvedReportsCount()).isEqualTo(2);
        }

        @Test
        void 모든_지표를_함께_반환한다() {
            // given
            saveUser("a@test.com", "provider_a", "유저A", "handleA");
            saveUser("b@test.com", "provider_b", "유저B", "handleB");

            saveStagingLabel(1L, "label_1", LabelStatus.PENDING);
            saveStagingLabel(2L, "label_2", LabelStatus.COMPLETED);

            saveReport(1L, 100L, false);
            saveReport(2L, 100L, true);
            saveReport(3L, 100L, false);

            // when
            AdminDashboardSummaryResponse result = adminDashboardService.getDashboardSummary();

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.totalUsers()).isEqualTo(2);
                softly.assertThat(result.pendingLabelsCount()).isEqualTo(1);
                softly.assertThat(result.unresolvedReportsCount()).isEqualTo(2);
            });
        }
    }
}
