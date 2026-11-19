package gravit.code.report.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.report.domain.UserReport;
import gravit.code.report.domain.UserReportType;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.dto.request.UserReportSubmitRequest;
import gravit.code.report.repository.ReportRepository;
import gravit.code.report.repository.UserReportRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.chapter.domain.ChapterCategory.CS;
import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_DUPLICATED;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_REPORT_SELF_NOT_ALLOWED;
import static gravit.code.report.fixture.UserReportFixture.처리된_닉네임_신고;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class ReportServiceIntegrationTest {

    @Autowired
    private ReportService reportService;

    @Autowired
    private ReportRepository reportRepository;

    @Autowired
    private ChapterRepository chapterRepository;

    @Autowired
    private UnitRepository unitRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private UserReportRepository userReportRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Nested
    @DisplayName("문제를 신고할 때")
    class SubmitProblemReport {

        @Test
        void 문제가_존재하면_신고가_저장된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초", CS));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId(), 1));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest("CONTENT_ERROR", "문제 내용이 잘못되었습니다.", problem.getId());

            // when
            reportService.submitProblemReport(userId, request);

            // then
            assertThat(reportRepository.existsReportByProblemIdAndUserId(problem.getId(), userId)).isTrue();
        }

        @Test
        void 신고_사유가_null이면_기본값으로_저장된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초", CS));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId(), 1));
            Lesson lesson = lessonRepository.save(Lesson.create("레슨1", unit.getId()));
            Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "빈칸을 채우시오.", "스택은 ___구조이다.", lesson.getId()));
            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest("TYPO_ERROR", null, problem.getId());

            // when
            reportService.submitProblemReport(userId, request);

            // then
            assertThat(reportRepository.count()).isEqualTo(1);
        }

        @Test
        void 문제가_존재하지_않으면_예외가_발생한다() {
            // given
            long userId = 1L;
            ProblemReportSubmitRequest request = new ProblemReportSubmitRequest("CONTENT_ERROR", "문제 내용이 잘못되었습니다.", 999L);

            // when & then
            assertThatThrownBy(() -> reportService.submitProblemReport(userId, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(PROBLEM_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("사용자를 신고할 때")
    class SubmitUserReport {

        private static final String NICKNAME_REPORT = "INAPPROPRIATE_NICKNAME";
        private static final String REPORT_CONTENT = "닉네임이 부적절해요.";

        private UserReportSubmitRequest 닉네임_신고(long targetUserId) {
            return new UserReportSubmitRequest(targetUserId, NICKNAME_REPORT, REPORT_CONTENT);
        }

        @Test
        void 신고가_저장되고_신고_시점의_닉네임이_남는다() {
            // given
            User reporter = userFixture.일반_유저(1);
            User target = userFixture.일반_유저(2);

            // when
            reportService.submitUserReport(reporter.getId(), 닉네임_신고(target.getId()));

            // then
            List<UserReport> reports = userReportRepository.findAll();
            assertThat(reports).hasSize(1);
            UserReport saved = reports.get(0);
            assertSoftly(softly -> {
                softly.assertThat(saved.getReporterId()).isEqualTo(reporter.getId());
                softly.assertThat(saved.getTargetUserId()).isEqualTo(target.getId());
                softly.assertThat(saved.getReportType()).isEqualTo(UserReportType.INAPPROPRIATE_NICKNAME);
                softly.assertThat(saved.getReportedNickname()).isEqualTo("유저2");
                softly.assertThat(saved.getContent()).isEqualTo(REPORT_CONTENT);
                softly.assertThat(saved.isResolved()).isFalse();
            });
        }

        @Test
        void 상세_사유_없이도_신고할_수_있다() {
            // given
            User reporter = userFixture.일반_유저(1);
            User target = userFixture.일반_유저(2);

            // when
            reportService.submitUserReport(reporter.getId(), new UserReportSubmitRequest(target.getId(), "OTHER", null));

            // then
            assertThat(userReportRepository.findAll())
                    .singleElement()
                    .satisfies(report -> {
                        assertThat(report.getReportType()).isEqualTo(UserReportType.OTHER);
                        assertThat(report.getContent()).isNull();
                    });
        }

        @Test
        void 자기_자신을_신고하면_예외를_던진다() {
            // given
            User reporter = userFixture.일반_유저(1);

            // when & then
            assertThatThrownBy(() -> reportService.submitUserReport(reporter.getId(), 닉네임_신고(reporter.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_REPORT_SELF_NOT_ALLOWED);
            assertThat(userReportRepository.count()).isZero();
        }

        @Test
        void 없는_사용자를_신고하면_예외를_던진다() {
            // given
            User reporter = userFixture.일반_유저(1);
            long nonExistentUserId = 99_999L;

            // when & then
            assertThatThrownBy(() -> reportService.submitUserReport(reporter.getId(), 닉네임_신고(nonExistentUserId)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 탈퇴한_사용자를_신고하면_예외를_던진다() {
            // given
            User reporter = userFixture.일반_유저(1);
            User target = userFixture.일반_유저(2);
            userRepository.deleteById(target.getId());

            // when & then
            assertThatThrownBy(() -> reportService.submitUserReport(reporter.getId(), 닉네임_신고(target.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 같은_대상에_처리되지_않은_내_신고가_있으면_예외를_던진다() {
            // given
            User reporter = userFixture.일반_유저(1);
            User target = userFixture.일반_유저(2);
            reportService.submitUserReport(reporter.getId(), 닉네임_신고(target.getId()));

            // when & then
            assertThatThrownBy(() -> reportService.submitUserReport(reporter.getId(), 닉네임_신고(target.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_REPORT_DUPLICATED);
            assertThat(userReportRepository.count()).isEqualTo(1);
        }

        @Test
        void 이전_신고가_처리된_뒤에는_다시_신고할_수_있다() {
            // given
            User reporter = userFixture.일반_유저(1);
            User target = userFixture.일반_유저(2);
            userReportRepository.save(처리된_닉네임_신고(reporter.getId(), target.getId()));

            // when
            reportService.submitUserReport(reporter.getId(), 닉네임_신고(target.getId()));

            // then
            assertThat(userReportRepository.count()).isEqualTo(2);
        }

        @Test
        void 다른_사용자가_같은_대상을_신고하는_것은_막지_않는다() {
            // given
            User reporter = userFixture.일반_유저(1);
            User otherReporter = userFixture.일반_유저(2);
            User target = userFixture.일반_유저(3);
            reportService.submitUserReport(reporter.getId(), 닉네임_신고(target.getId()));

            // when
            reportService.submitUserReport(otherReporter.getId(), 닉네임_신고(target.getId()));

            // then
            assertThat(userReportRepository.count()).isEqualTo(2);
        }
    }
}
