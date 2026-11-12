package gravit.code.admin.service;

import gravit.code.admin.dto.request.LessonUpdateRequest;
import gravit.code.admin.dto.response.LessonDetailResponse;
import gravit.code.admin.dto.response.ProblemListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class AdminLessonServiceIntegrationTest {

    private static final long UNIT_ID = 10L;

    @Autowired
    private AdminLessonService adminLessonService;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private ProblemRepository problemRepository;

    @Test
    @DisplayName("레슨 상세: problemCount 포함")
    void getLesson_withProblemCount() {
        Lesson lesson = lessonRepository.save(Lesson.create("레슨", UNIT_ID));
        problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "지시문", "내용", lesson.getId()));
        problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지시문", "내용", lesson.getId()));

        LessonDetailResponse detail = adminLessonService.getLesson(lesson.getId());

        assertThat(detail.lessonId()).isEqualTo(lesson.getId());
        assertThat(detail.unitId()).isEqualTo(UNIT_ID);
        assertThat(detail.problemCount()).isEqualTo(2);
    }

    @Test
    @DisplayName("레슨 상세 없음 -> LESSON_NOT_FOUND")
    void getLesson_notFound() {
        assertThatThrownBy(() -> adminLessonService.getLesson(99999L))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.LESSON_NOT_FOUND);
    }

    @Test
    @DisplayName("레슨 제목 수정")
    void updateLesson_title() {
        Lesson lesson = lessonRepository.save(Lesson.create("원제목", UNIT_ID));

        adminLessonService.updateLesson(lesson.getId(), new LessonUpdateRequest("새제목"));

        assertThat(adminLessonService.getLesson(lesson.getId()).title()).isEqualTo("새제목");
    }

    @Test
    @DisplayName("레슨의 문제 목록 조회")
    void getProblems() {
        Lesson lesson = lessonRepository.save(Lesson.create("레슨", UNIT_ID));
        problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "지시문", "내용", lesson.getId()));
        problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지시문", "내용", lesson.getId()));

        PageResponse<ProblemListItemResponse> result = adminLessonService.getProblems(lesson.getId(), 1);

        assertThat(result.contents()).hasSize(2);
    }
}
