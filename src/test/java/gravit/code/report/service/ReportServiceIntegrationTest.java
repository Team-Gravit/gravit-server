package gravit.code.report.service;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.repository.ChapterRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.report.dto.request.ProblemReportSubmitRequest;
import gravit.code.report.repository.ReportRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.unit.domain.Unit;
import gravit.code.unit.repository.UnitRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.PROBLEM_NOT_FOUND;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
@Transactional
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

    @Nested
    @DisplayName("문제를 신고할 때")
    class SubmitProblemReport {

        @Test
        void 문제가_존재하면_신고가_저장된다() {
            // given
            long userId = 1L;
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
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
            Chapter chapter = chapterRepository.save(Chapter.create("자료구조", "자료구조 기초"));
            Unit unit = unitRepository.save(Unit.create("연결리스트", "배열과 연결리스트", chapter.getId()));
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
}
