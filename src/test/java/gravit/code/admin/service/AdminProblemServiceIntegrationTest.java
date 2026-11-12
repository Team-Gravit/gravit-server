package gravit.code.admin.service;

import gravit.code.admin.dto.request.ObjectiveOptionUpdateRequest;
import gravit.code.admin.dto.request.ObjectiveProblemUpdateRequest;
import gravit.code.admin.dto.request.SubjectiveAnswerUpdateRequest;
import gravit.code.admin.dto.request.SubjectiveProblemUpdateRequest;
import gravit.code.admin.dto.response.ProblemDetailResponse;
import gravit.code.admin.dto.response.ProblemOptionResponse;
import gravit.code.answer.domain.Answer;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.option.domain.Option;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class AdminProblemServiceIntegrationTest {

    private static final long LESSON_ID = 10L;

    @Autowired
    private AdminProblemService adminProblemService;

    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private OptionRepository optionRepository;

    @Autowired
    private AnswerRepository answerRepository;

    private Problem saveObjectiveWithOptions() {
        Problem problem = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "지시문", "내용", LESSON_ID));
        optionRepository.save(Option.create("정답옵션", "해설", true, problem.getId()));
        optionRepository.save(Option.create("오답1", "해설", false, problem.getId()));
        optionRepository.save(Option.create("오답2", "해설", false, problem.getId()));
        optionRepository.save(Option.create("오답3", "해설", false, problem.getId()));
        return problem;
    }

    @Test
    @DisplayName("객관식 상세: options 4개(id ASC), answer null")
    void getProblem_objective() {
        Problem problem = saveObjectiveWithOptions();

        ProblemDetailResponse detail = adminProblemService.getProblem(problem.getId());

        assertSoftly(softly -> {
            softly.assertThat(detail.problemType()).isEqualTo(ProblemType.OBJECTIVE);
            softly.assertThat(detail.options()).hasSize(4);
            softly.assertThat(detail.answer()).isNull();
            softly.assertThat(detail.options().get(0).isAnswer()).isTrue();
        });
    }

    @Test
    @DisplayName("주관식 상세: answer 단일, options null")
    void getProblem_subjective() {
        Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지시문", "내용", LESSON_ID));
        answerRepository.save(Answer.create("정답", "해설", problem.getId()));

        ProblemDetailResponse detail = adminProblemService.getProblem(problem.getId());

        assertSoftly(softly -> {
            softly.assertThat(detail.problemType()).isEqualTo(ProblemType.SUBJECTIVE);
            softly.assertThat(detail.answer()).isNotNull();
            softly.assertThat(detail.options()).isNull();
        });
    }

    @Test
    @DisplayName("객관식 상세: 옵션 없으면 OPTION_NOT_FOUND")
    void getProblem_objective_noOptions() {
        Problem problem = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "지시문", "내용", LESSON_ID));

        assertThatThrownBy(() -> adminProblemService.getProblem(problem.getId()))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.OPTION_NOT_FOUND);
    }

    @Test
    @DisplayName("객관식 수정: instruction/content 부분 수정 + 옵션 4개 교체")
    void updateObjective() {
        Problem problem = saveObjectiveWithOptions();
        List<Option> options = optionRepository.findByProblemIdOrderById(problem.getId());
        List<ObjectiveOptionUpdateRequest> optionRequests = options.stream()
                .map(o -> new ObjectiveOptionUpdateRequest(o.getId(), "수정옵션" + o.getId(), "수정해설", o.isAnswer()))
                .toList();

        adminProblemService.updateObjective(problem.getId(),
                new ObjectiveProblemUpdateRequest("새지시문", "새본문", optionRequests));

        ProblemDetailResponse detail = adminProblemService.getProblem(problem.getId());
        assertSoftly(softly -> {
            softly.assertThat(detail.instruction()).isEqualTo("새지시문");
            softly.assertThat(detail.content()).isEqualTo("새본문");
            softly.assertThat(detail.options().get(0).content()).startsWith("수정옵션");
            softly.assertThat(detail.options().stream().filter(ProblemOptionResponse::isAnswer).count()).isEqualTo(1);
        });
    }

    @Test
    @DisplayName("객관식 수정: 정답이 1개가 아니면 OBJECTIVE_OPTIONS_INVALID")
    void updateObjective_invalidAnswerCount() {
        Problem problem = saveObjectiveWithOptions();
        List<Option> options = optionRepository.findByProblemIdOrderById(problem.getId());
        List<ObjectiveOptionUpdateRequest> allFalse = options.stream()
                .map(o -> new ObjectiveOptionUpdateRequest(o.getId(), "옵션", "해설", false))
                .toList();

        assertThatThrownBy(() -> adminProblemService.updateObjective(problem.getId(),
                new ObjectiveProblemUpdateRequest(null, null, allFalse)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.OBJECTIVE_OPTIONS_INVALID);
    }

    @Test
    @DisplayName("주관식 수정: answer content/explanation 수정")
    void updateSubjective() {
        Problem problem = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지시문", "내용", LESSON_ID));
        Answer answer = answerRepository.save(Answer.create("정답", "해설", problem.getId()));

        adminProblemService.updateSubjective(problem.getId(),
                new SubjectiveProblemUpdateRequest("새지시문", "새본문",
                        new SubjectiveAnswerUpdateRequest(answer.getId(), "0,영,zero", "새해설")));

        ProblemDetailResponse detail = adminProblemService.getProblem(problem.getId());
        assertSoftly(softly -> {
            softly.assertThat(detail.instruction()).isEqualTo("새지시문");
            softly.assertThat(detail.answer().content()).isEqualTo("0,영,zero");
            softly.assertThat(detail.answer().explanation()).isEqualTo("새해설");
        });
    }

    @Test
    @DisplayName("객관식 수정 엔드포인트에 주관식 문제 요청 시 PROBLEM_TYPE_MISMATCH")
    void updateObjective_onSubjectiveProblem_typeMismatch() {
        Problem subjective = problemRepository.save(Problem.create(ProblemType.SUBJECTIVE, "지시문", "내용", LESSON_ID));

        assertThatThrownBy(() -> adminProblemService.updateObjective(subjective.getId(),
                new ObjectiveProblemUpdateRequest("새지시문", null, null)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.PROBLEM_TYPE_MISMATCH);
    }

    @Test
    @DisplayName("주관식 수정 엔드포인트에 객관식 문제 요청 시 PROBLEM_TYPE_MISMATCH")
    void updateSubjective_onObjectiveProblem_typeMismatch() {
        Problem objective = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "지시문", "내용", LESSON_ID));

        assertThatThrownBy(() -> adminProblemService.updateSubjective(objective.getId(),
                new SubjectiveProblemUpdateRequest("새지시문", null, null)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.PROBLEM_TYPE_MISMATCH);
    }

    @Test
    @DisplayName("객관식 수정 시 다른 문제 소속 옵션이 섞이면 OPTION_NOT_IN_PROBLEM")
    void updateObjective_optionFromAnotherProblem() {
        Problem problem = saveObjectiveWithOptions();
        Problem other = problemRepository.save(Problem.create(ProblemType.OBJECTIVE, "지시문", "내용", LESSON_ID));
        Option foreign = optionRepository.save(Option.create("외부옵션", "해설", false, other.getId()));

        List<Option> options = optionRepository.findByProblemIdOrderById(problem.getId());
        // 정답 1개 유지하되 비정답 1개를 다른 문제의 옵션으로 교체 (개수/정답 검증은 통과, 소속 검증에서 실패)
        List<ObjectiveOptionUpdateRequest> requests = List.of(
                new ObjectiveOptionUpdateRequest(options.get(0).getId(), "수정", "해설", true),
                new ObjectiveOptionUpdateRequest(options.get(1).getId(), "수정", "해설", false),
                new ObjectiveOptionUpdateRequest(options.get(2).getId(), "수정", "해설", false),
                new ObjectiveOptionUpdateRequest(foreign.getId(), "수정", "해설", false)
        );

        assertThatThrownBy(() -> adminProblemService.updateObjective(problem.getId(),
                new ObjectiveProblemUpdateRequest(null, null, requests)))
                .isInstanceOf(RestApiException.class)
                .extracting(e -> ((RestApiException) e).getErrorCode())
                .isEqualTo(CustomErrorCode.OPTION_NOT_IN_PROBLEM);
    }
}
