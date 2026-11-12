package gravit.code.admin.service;

import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.domain.staging.OptionStaging;
import gravit.code.admin.domain.staging.StagingLabel;
import gravit.code.admin.dto.request.StagingAnswerUpdateRequest;
import gravit.code.admin.dto.request.StagingLessonUpdateRequest;
import gravit.code.admin.dto.request.StagingOptionUpdateRequest;
import gravit.code.admin.dto.request.StagingProblemUpdateRequest;
import gravit.code.admin.dto.response.StagingLabelDetailResponse;
import gravit.code.admin.dto.response.StagingLabelListItemResponse;
import gravit.code.admin.fixture.StagingFixture;
import gravit.code.admin.repository.AnswerStagingRepository;
import gravit.code.admin.repository.LessonStagingRepository;
import gravit.code.admin.repository.OptionStagingRepository;
import gravit.code.admin.repository.ProblemStagingRepository;
import gravit.code.admin.repository.StagingLabelRepository;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemType;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminStagingServiceIntegrationTest {

    private static final String LABEL = "2026-04-25-a3f9";

    @Autowired
    private AdminStagingService adminStagingService;

    @Autowired
    private StagingLabelRepository stagingLabelRepository;

    @Autowired
    private LessonStagingRepository lessonStagingRepository;

    @Autowired
    private ProblemStagingRepository problemStagingRepository;

    @Autowired
    private OptionStagingRepository optionStagingRepository;

    @Autowired
    private AnswerStagingRepository answerStagingRepository;

    private void saveFullLabel(String label, LabelStatus status) {
        StagingLabel stagingLabel = StagingFixture.라벨(1L, label, 5L);
        if (status == LabelStatus.COMPLETED) {
            stagingLabel.complete();
        }
        stagingLabelRepository.save(stagingLabel);
        lessonStagingRepository.save(StagingFixture.레슨(10L, 5L, label));
        problemStagingRepository.save(StagingFixture.문제(20L, 10L, ProblemType.OBJECTIVE, label));
        problemStagingRepository.save(StagingFixture.문제(21L, 10L, ProblemType.SUBJECTIVE, label));
        optionStagingRepository.save(StagingFixture.옵션(30L, 20L, true, label));
        optionStagingRepository.save(StagingFixture.옵션(31L, 20L, false, label));
        optionStagingRepository.save(StagingFixture.옵션(32L, 20L, false, label));
        optionStagingRepository.save(StagingFixture.옵션(33L, 20L, false, label));
        answerStagingRepository.save(StagingFixture.정답(40L, 21L, label));
    }

    @Test
    @DisplayName("라벨 목록: status 필터")
    void getLabels_filterByStatus() {
        stagingLabelRepository.save(StagingFixture.라벨(1L, "2026-01-01-aaaa", 5L));
        StagingLabel completed = StagingFixture.라벨(2L, "2026-01-01-bbbb", 5L);
        completed.complete();
        stagingLabelRepository.save(completed);

        PageResponse<StagingLabelListItemResponse> pending = adminStagingService.getLabels(1, LabelStatus.PENDING);
        PageResponse<StagingLabelListItemResponse> all = adminStagingService.getLabels(1, null);

        assertThat(pending.contents()).hasSize(1);
        assertThat(pending.contents().get(0).status()).isEqualTo(LabelStatus.PENDING);
        assertThat(all.contents()).hasSize(2);
    }

    @Test
    @DisplayName("라벨 상세: lesson + problems(options/answer) 그루핑")
    void getLabelDetail() {
        saveFullLabel(LABEL, LabelStatus.PENDING);

        StagingLabelDetailResponse detail = adminStagingService.getLabelDetail(LABEL);

        assertSoftly(softly -> {
            softly.assertThat(detail.label()).isEqualTo(LABEL);
            softly.assertThat(detail.lesson().lessonId()).isEqualTo(10L);
            softly.assertThat(detail.problems()).hasSize(2);
            var objective = detail.problems().stream().filter(p -> p.problemType() == ProblemType.OBJECTIVE).findFirst().orElseThrow();
            var subjective = detail.problems().stream().filter(p -> p.problemType() == ProblemType.SUBJECTIVE).findFirst().orElseThrow();
            softly.assertThat(objective.options()).hasSize(4);
            softly.assertThat(objective.answer()).isNull();
            softly.assertThat(subjective.answer()).isNotNull();
            softly.assertThat(subjective.options()).isNull();
        });
    }

    @Test
    @DisplayName("라벨 상세 없음 -> STAGING_LABEL_NOT_FOUND")
    void getLabelDetail_notFound() {
        assertThatThrownBy(() -> adminStagingService.getLabelDetail("2099-12-31-ffff"))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.STAGING_LABEL_NOT_FOUND);
    }

    @Test
    @DisplayName("스테이징 레슨 수정 (PENDING)")
    void updateLesson() {
        saveFullLabel(LABEL, LabelStatus.PENDING);

        adminStagingService.updateLesson(10L, new StagingLessonUpdateRequest("수정된 레슨"));

        assertThat(lessonStagingRepository.findById(10L).orElseThrow().getTitle()).isEqualTo("수정된 레슨");
    }

    @Test
    @DisplayName("스테이징 문제 부분 수정")
    void updateProblem_partial() {
        saveFullLabel(LABEL, LabelStatus.PENDING);

        adminStagingService.updateProblem(20L, new StagingProblemUpdateRequest("수정 지시문", null));

        var problem = problemStagingRepository.findById(20L).orElseThrow();
        assertThat(problem.getInstruction()).isEqualTo("수정 지시문");
        assertThat(problem.getContent()).isEqualTo("내용 20"); // content 미제공 -> 유지
    }

    @Test
    @DisplayName("스테이징 옵션 부분 수정 (isAnswer 미제공 시 유지)")
    void updateOption_partial() {
        saveFullLabel(LABEL, LabelStatus.PENDING);

        adminStagingService.updateOption(30L, new StagingOptionUpdateRequest("수정 옵션", null, null));

        OptionStaging option = optionStagingRepository.findById(30L).orElseThrow();
        assertThat(option.getContent()).isEqualTo("수정 옵션");
        assertThat(option.isAnswer()).isTrue(); // 유지
    }

    @Test
    @DisplayName("스테이징 정답 부분 수정")
    void updateAnswer_partial() {
        saveFullLabel(LABEL, LabelStatus.PENDING);

        adminStagingService.updateAnswer(40L, new StagingAnswerUpdateRequest("수정 정답", null));

        assertThat(answerStagingRepository.findById(40L).orElseThrow().getContent()).isEqualTo("수정 정답");
    }

    @Test
    @DisplayName("COMPLETED 라벨의 staging 수정은 409 STAGING_LABEL_ALREADY_COMPLETED")
    void update_completedLabel_conflict() {
        saveFullLabel(LABEL, LabelStatus.COMPLETED);

        assertThatThrownBy(() -> adminStagingService.updateLesson(10L, new StagingLessonUpdateRequest("x")))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.STAGING_LABEL_ALREADY_COMPLETED);
    }
}
