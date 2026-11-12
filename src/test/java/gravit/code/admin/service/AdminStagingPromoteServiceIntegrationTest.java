package gravit.code.admin.service;

import gravit.code.admin.domain.audit.AuditAction;
import gravit.code.admin.domain.audit.AuditLog;
import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.fixture.StagingFixture;
import gravit.code.admin.repository.AnswerStagingRepository;
import gravit.code.admin.repository.AuditLogRepository;
import gravit.code.admin.repository.LessonStagingRepository;
import gravit.code.admin.repository.OptionStagingRepository;
import gravit.code.admin.repository.ProblemStagingRepository;
import gravit.code.admin.repository.StagingLabelRepository;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminStagingPromoteServiceIntegrationTest {

    private static final long ADMIN_ID = 1L;
    private static final String LABEL = "2026-04-25-a3f9";

    @Autowired
    private AdminStagingPromoteService adminStagingPromoteService;

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

    @Autowired
    private LessonRepository lessonRepository;
    @Autowired
    private ProblemRepository problemRepository;
    @Autowired
    private OptionRepository optionRepository;
    @Autowired
    private AnswerRepository answerRepository;
    @Autowired
    private AuditLogRepository auditLogRepository;

    /** 유효 라벨: lesson 1 + problem 6(OBJ4+SUBJ2) + 각 OBJ 옵션4(정답1) + 각 SUBJ 정답1 */
    private void persistValidLabel(String label) {
        stagingLabelRepository.save(StagingFixture.라벨(1L, label, 5L));
        lessonStagingRepository.save(StagingFixture.레슨(10L, 5L, label));

        long optionId = 100L;
        for (long problemId : new long[]{20L, 21L, 22L, 23L}) {
            problemStagingRepository.save(StagingFixture.문제(problemId, 10L, ProblemType.OBJECTIVE, label));
            for (int i = 0; i < 4; i++) {
                optionStagingRepository.save(StagingFixture.옵션(optionId++, problemId, i == 0, label));
            }
        }
        long answerId = 200L;
        for (long problemId : new long[]{24L, 25L}) {
            problemStagingRepository.save(StagingFixture.문제(problemId, 10L, ProblemType.SUBJECTIVE, label));
            answerStagingRepository.save(StagingFixture.정답(answerId++, problemId, label));
        }
    }

    @Test
    @DisplayName("promote: prod INSERT + ID 리매핑 + 라벨 COMPLETED + 감사로그, staging 보존")
    void promote_success() {
        persistValidLabel(LABEL);

        adminStagingPromoteService.promote(ADMIN_ID, LABEL, LabelStatus.COMPLETED);

        // prod 적재 개수
        assertSoftly(softly -> {
            softly.assertThat(lessonRepository.count()).isEqualTo(1);
            softly.assertThat(problemRepository.count()).isEqualTo(6);
            softly.assertThat(optionRepository.count()).isEqualTo(16);
            softly.assertThat(answerRepository.count()).isEqualTo(2);
        });

        // ID 리매핑: prod child FK 가 prod 부모를 가리킨다 (staging id 누수 없음)
        Lesson prodLesson = lessonRepository.findAll().get(0);
        List<Problem> prodProblems = problemRepository.findAll();
        Set<Long> prodProblemIds = prodProblems.stream().map(Problem::getId).collect(Collectors.toSet());
        assertSoftly(softly -> {
            softly.assertThat(prodLesson.getUnitId()).isEqualTo(5L);
            softly.assertThat(prodProblems).allMatch(p -> p.getLessonId() == prodLesson.getId());
            softly.assertThat(optionRepository.findAll()).allMatch(o -> prodProblemIds.contains(o.getProblemId()));
            softly.assertThat(answerRepository.findAll()).allMatch(a -> prodProblemIds.contains(a.getProblemId()));
        });

        // 라벨 COMPLETED + staging 보존
        assertThat(stagingLabelRepository.findByLabel(LABEL).orElseThrow().getStatus()).isEqualTo(LabelStatus.COMPLETED);
        assertThat(problemStagingRepository.findByLabelOrderById(LABEL)).hasSize(6);

        // 감사로그
        List<AuditLog> logs = auditLogRepository.findAll();
        assertThat(logs).hasSize(1);
        assertThat(logs.get(0).getAction()).isEqualTo(AuditAction.STAGING_PROMOTE);
        assertThat(logs.get(0).getTargetId()).isEqualTo(LABEL);
    }

    @Test
    @DisplayName("promote: status != COMPLETED 면 400 STAGING_STATUS_INVALID")
    void promote_invalidStatus() {
        persistValidLabel(LABEL);

        assertThatThrownBy(() -> adminStagingPromoteService.promote(ADMIN_ID, LABEL, LabelStatus.PENDING))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.STAGING_STATUS_INVALID);
    }

    @Test
    @DisplayName("promote: 라벨 없음 -> STAGING_LABEL_NOT_FOUND")
    void promote_labelNotFound() {
        assertThatThrownBy(() -> adminStagingPromoteService.promote(ADMIN_ID, "2099-12-31-ffff", LabelStatus.COMPLETED))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.STAGING_LABEL_NOT_FOUND);
    }

    @Test
    @DisplayName("promote: 이미 COMPLETED 면 409 STAGING_LABEL_ALREADY_COMPLETED")
    void promote_alreadyCompleted() {
        persistValidLabel(LABEL);
        adminStagingPromoteService.promote(ADMIN_ID, LABEL, LabelStatus.COMPLETED);

        assertThatThrownBy(() -> adminStagingPromoteService.promote(ADMIN_ID, LABEL, LabelStatus.COMPLETED))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.STAGING_LABEL_ALREADY_COMPLETED);
    }

    @Test
    @DisplayName("promote: 불변식 위반(문제 6개 아님) -> 400 STAGING_INVALID_STRUCTURE, 롤백")
    void promote_invalidStructure() {
        // 문제 5개만 (OBJ 4 + SUBJ 1)
        stagingLabelRepository.save(StagingFixture.라벨(1L, LABEL, 5L));
        lessonStagingRepository.save(StagingFixture.레슨(10L, 5L, LABEL));
        long optionId = 100L;
        for (long problemId : new long[]{20L, 21L, 22L, 23L}) {
            problemStagingRepository.save(StagingFixture.문제(problemId, 10L, ProblemType.OBJECTIVE, LABEL));
            for (int i = 0; i < 4; i++) {
                optionStagingRepository.save(StagingFixture.옵션(optionId++, problemId, i == 0, LABEL));
            }
        }
        problemStagingRepository.save(StagingFixture.문제(24L, 10L, ProblemType.SUBJECTIVE, LABEL));
        answerStagingRepository.save(StagingFixture.정답(200L, 24L, LABEL));

        assertThatThrownBy(() -> adminStagingPromoteService.promote(ADMIN_ID, LABEL, LabelStatus.COMPLETED))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.STAGING_INVALID_STRUCTURE);

        // 롤백: prod 미적재, 라벨 PENDING 유지
        assertThat(lessonRepository.count()).isZero();
        assertThat(problemRepository.count()).isZero();
        assertThat(stagingLabelRepository.findByLabel(LABEL).orElseThrow().getStatus()).isEqualTo(LabelStatus.PENDING);
    }

    @Test
    @DisplayName("promote: option 이 라벨 문제 목록 밖 problemId 참조 시 STAGING_INVALID_STRUCTURE (NPE 방지)")
    void promote_optionReferencesUnknownProblem() {
        persistValidLabel(LABEL);
        // 라벨의 어떤 문제에도 속하지 않는 problemId(88888) 를 참조하는 옵션 추가
        optionStagingRepository.save(StagingFixture.옵션(999L, 88888L, false, LABEL));

        assertThatThrownBy(() -> adminStagingPromoteService.promote(ADMIN_ID, LABEL, LabelStatus.COMPLETED))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.STAGING_INVALID_STRUCTURE);

        assertThat(lessonRepository.count()).isZero(); // 롤백
    }
}
