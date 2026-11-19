package gravit.code.admin.service;

import gravit.code.admin.dto.response.UserReportListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.report.domain.UserReport;
import gravit.code.report.domain.UserReportType;
import gravit.code.report.repository.UserReportRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_DUPLICATED;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_NOT_FOUND;
import static gravit.code.report.fixture.UserReportFixture.미처리_기타_신고;
import static gravit.code.report.fixture.UserReportFixture.미처리_닉네임_신고;
import static gravit.code.report.fixture.UserReportFixture.처리된_닉네임_신고;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminUserReportServiceIntegrationTest {

    private static final int FIRST_PAGE = 1;
    private static final long REPORTER_ID = 1L;
    private static final long OTHER_REPORTER_ID = 2L;
    private static final long THIRD_REPORTER_ID = 3L;
    private static final long TARGET_USER_ID = 10L;

    @Autowired
    private AdminUserReportService adminUserReportService;

    @Autowired
    private UserReportRepository userReportRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Nested
    @DisplayName("사용자 신고 목록을 조회할 때")
    class GetUserReports {

        @Test
        void 필터가_없으면_전체를_최신순으로_돌려준다() {
            // given
            UserReport first = userReportRepository.save(미처리_닉네임_신고(REPORTER_ID, TARGET_USER_ID));
            UserReport second = userReportRepository.save(미처리_기타_신고(OTHER_REPORTER_ID, TARGET_USER_ID));

            // when
            PageResponse<UserReportListItemResponse> result = adminUserReportService.getUserReports(FIRST_PAGE, null, null);

            // then
            assertThat(result.contents())
                    .extracting(UserReportListItemResponse::reportId)
                    .containsExactly(second.getId(), first.getId());
        }

        @Test
        void 신고_사유로_거른다() {
            // given
            UserReport nicknameReport = userReportRepository.save(미처리_닉네임_신고(REPORTER_ID, TARGET_USER_ID));
            userReportRepository.save(미처리_기타_신고(OTHER_REPORTER_ID, TARGET_USER_ID));

            // when
            PageResponse<UserReportListItemResponse> result =
                    adminUserReportService.getUserReports(FIRST_PAGE, UserReportType.INAPPROPRIATE_NICKNAME, null);

            // then
            assertThat(result.contents())
                    .extracting(UserReportListItemResponse::reportId)
                    .containsExactly(nicknameReport.getId());
        }

        @Test
        void 처리_여부로_거른다() {
            // given
            userReportRepository.save(처리된_닉네임_신고(REPORTER_ID, TARGET_USER_ID));
            UserReport unresolved = userReportRepository.save(미처리_닉네임_신고(OTHER_REPORTER_ID, TARGET_USER_ID));

            // when
            PageResponse<UserReportListItemResponse> result = adminUserReportService.getUserReports(FIRST_PAGE, null, false);

            // then
            assertThat(result.contents())
                    .extracting(UserReportListItemResponse::reportId)
                    .containsExactly(unresolved.getId());
        }

        @Test
        void 신고자와_대상과_신고_시점_닉네임을_함께_돌려준다() {
            // given
            UserReport saved = userReportRepository.save(미처리_닉네임_신고(REPORTER_ID, TARGET_USER_ID));

            // when
            PageResponse<UserReportListItemResponse> result = adminUserReportService.getUserReports(FIRST_PAGE, null, null);

            // then
            UserReportListItemResponse item = result.contents().get(0);
            assertSoftly(softly -> {
                softly.assertThat(item.reporterId()).isEqualTo(REPORTER_ID);
                softly.assertThat(item.targetUserId()).isEqualTo(TARGET_USER_ID);
                softly.assertThat(item.reportType()).isEqualTo(UserReportType.INAPPROPRIATE_NICKNAME);
                softly.assertThat(item.reportedNickname()).isEqualTo(saved.getReportedNickname());
                softly.assertThat(item.content()).isEqualTo(saved.getContent());
                softly.assertThat(item.isResolved()).isFalse();
            });
        }
    }

    @Nested
    @DisplayName("사용자 신고 처리 상태를 바꿀 때")
    class UpdateResolved {

        @BeforeEach
        void setUp() {
            운영_스키마와_같은_미처리_중복_방지_인덱스를_건다();
        }

        private void 운영_스키마와_같은_미처리_중복_방지_인덱스를_건다() {
            // 테스트 스키마는 Hibernate가 만들어 V54의 부분 유니크 인덱스가 없다
            jdbcTemplate.execute("""
                    CREATE UNIQUE INDEX IF NOT EXISTS ux_user_report_unresolved_pair
                        ON user_report (reporter_id, target_user_id)
                        WHERE is_resolved = false
                    """);
        }

        @Test
        void 처리_완료로_바꾼다() {
            // given
            UserReport report = userReportRepository.save(미처리_닉네임_신고(REPORTER_ID, TARGET_USER_ID));

            // when
            adminUserReportService.updateResolved(report.getId(), true);

            // then
            assertThat(userReportRepository.findById(report.getId()).orElseThrow().isResolved()).isTrue();
        }

        @Test
        void 처리되지_않은_상태로_되돌린다() {
            // given
            UserReport report = userReportRepository.save(처리된_닉네임_신고(REPORTER_ID, TARGET_USER_ID));

            // when
            adminUserReportService.updateResolved(report.getId(), false);

            // then
            assertThat(userReportRepository.findById(report.getId()).orElseThrow().isResolved()).isFalse();
        }

        @Test
        void 되돌릴_때_같은_신고자와_대상의_미처리_신고가_있으면_예외를_던진다() {
            // given
            UserReport resolved = userReportRepository.save(처리된_닉네임_신고(REPORTER_ID, TARGET_USER_ID));
            userReportRepository.save(미처리_닉네임_신고(REPORTER_ID, TARGET_USER_ID));

            // when & then
            assertThatThrownBy(() -> adminUserReportService.updateResolved(resolved.getId(), false))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_REPORT_DUPLICATED);
            assertThat(userReportRepository.findById(resolved.getId()).orElseThrow().isResolved()).isTrue();
        }

        @Test
        void 다른_신고자의_미처리_신고는_되돌리기를_막지_않는다() {
            // given
            UserReport resolved = userReportRepository.save(처리된_닉네임_신고(REPORTER_ID, TARGET_USER_ID));
            userReportRepository.save(미처리_닉네임_신고(THIRD_REPORTER_ID, TARGET_USER_ID));

            // when
            adminUserReportService.updateResolved(resolved.getId(), false);

            // then
            assertThat(userReportRepository.findById(resolved.getId()).orElseThrow().isResolved()).isFalse();
        }

        @Test
        void 없는_신고이면_예외를_던진다() {
            // given
            long nonExistentReportId = 99_999L;

            // when & then
            assertThatThrownBy(() -> adminUserReportService.updateResolved(nonExistentReportId, true))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_REPORT_NOT_FOUND);
        }
    }
}
