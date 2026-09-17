package gravit.code.admin.service;

import gravit.code.admin.domain.staging.AnswerStaging;
import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.domain.staging.LessonStaging;
import gravit.code.admin.domain.staging.OptionStaging;
import gravit.code.admin.domain.staging.ProblemStaging;
import gravit.code.admin.domain.staging.StagingLabel;
import gravit.code.admin.dto.request.StagingAnswerUpdateRequest;
import gravit.code.admin.dto.request.StagingLessonUpdateRequest;
import gravit.code.admin.dto.request.StagingOptionUpdateRequest;
import gravit.code.admin.dto.request.StagingProblemUpdateRequest;
import gravit.code.admin.dto.response.StagingLabelDetailResponse;
import gravit.code.admin.dto.response.StagingLabelListItemResponse;
import gravit.code.admin.dto.response.StagingLessonResponse;
import gravit.code.admin.dto.response.StagingProblemResponse;
import gravit.code.admin.repository.AnswerStagingRepository;
import gravit.code.admin.repository.LessonStagingRepository;
import gravit.code.admin.repository.OptionStagingRepository;
import gravit.code.admin.repository.ProblemStagingRepository;
import gravit.code.admin.repository.StagingLabelRepository;
import gravit.code.admin.support.AdminPages;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.problem.domain.ProblemType;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_ANSWER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_LABEL_ALREADY_COMPLETED;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_LABEL_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_LESSON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_OPTION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_PROBLEM_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminStagingService {

    private final StagingLabelRepository stagingLabelRepository;
    private final LessonStagingRepository lessonStagingRepository;
    private final ProblemStagingRepository problemStagingRepository;
    private final OptionStagingRepository optionStagingRepository;
    private final AnswerStagingRepository answerStagingRepository;

    @Transactional(readOnly = true)
    public PageResponse<StagingLabelListItemResponse> getLabels(
            int page,
            LabelStatus status
    ) {
        Pageable pageable = AdminPages.of(page, Sort.by(Sort.Direction.DESC, "createdAt").and(Sort.by(Sort.Direction.DESC, "id")));

        Page<StagingLabel> labels = (status == null)
                ? stagingLabelRepository.findAll(pageable)
                : stagingLabelRepository.findByStatus(status, pageable);

        return PageResponse.from(labels.map(StagingLabelListItemResponse::from));
    }

    @Transactional(readOnly = true)
    public StagingLabelDetailResponse getLabelDetail(String label) {
        StagingLabel stagingLabel = stagingLabelRepository.findByLabel(label)
                .orElseThrow(() -> new RestApiException(STAGING_LABEL_NOT_FOUND));

        LessonStaging lesson = lessonStagingRepository.findByLabel(label)
                .orElseThrow(() -> new RestApiException(STAGING_LESSON_NOT_FOUND));

        List<ProblemStaging> problems = problemStagingRepository.findByLabelOrderById(label);

        Map<Long, List<OptionStaging>> problemIdToOptions = optionStagingRepository.findByLabelOrderById(label).stream()
                .collect(Collectors.groupingBy(OptionStaging::getProblemId));

        Map<Long, List<AnswerStaging>> problemIdToAnswers = answerStagingRepository.findByLabelOrderById(label).stream()
                .filter(answer -> answer.getProblemId() != null)
                .collect(Collectors.groupingBy(AnswerStaging::getProblemId));

        List<StagingProblemResponse> problemResponses = problems.stream()
                .map(problem -> toProblemResponse(problem, problemIdToOptions, problemIdToAnswers))
                .toList();

        return StagingLabelDetailResponse.of(stagingLabel, StagingLessonResponse.from(lesson), problemResponses);
    }

    @Transactional
    public void updateLesson(
            long lessonId,
            StagingLessonUpdateRequest request
    ) {
        LessonStaging lesson = lessonStagingRepository.findById(lessonId)
                .orElseThrow(() -> new RestApiException(STAGING_LESSON_NOT_FOUND));

        guardNotCompleted(lesson.getLabel());

        lesson.updateTitle(request.title());
    }

    @Transactional
    public void updateProblem(
            long problemId,
            StagingProblemUpdateRequest request
    ) {
        ProblemStaging problem = problemStagingRepository.findById(problemId)
                .orElseThrow(() -> new RestApiException(STAGING_PROBLEM_NOT_FOUND));

        guardNotCompleted(problem.getLabel());

        String instruction = request.instruction() != null ? request.instruction() : problem.getInstruction();
        String content = request.content() != null ? request.content() : problem.getContent();

        problem.updateContent(instruction, content);
    }

    @Transactional
    public void updateOption(
            long optionId,
            StagingOptionUpdateRequest request
    ) {
        OptionStaging option = optionStagingRepository.findById(optionId)
                .orElseThrow(() -> new RestApiException(STAGING_OPTION_NOT_FOUND));

        guardNotCompleted(option.getLabel());

        String content = request.content() != null ? request.content() : option.getContent();
        String explanation = request.explanation() != null ? request.explanation() : option.getExplanation();
        boolean isAnswer = request.isAnswer() != null ? request.isAnswer() : option.isAnswer();

        option.update(content, explanation, isAnswer);
    }

    @Transactional
    public void updateAnswer(
            long answerId,
            StagingAnswerUpdateRequest request
    ) {
        AnswerStaging answer = answerStagingRepository.findById(answerId)
                .orElseThrow(() -> new RestApiException(STAGING_ANSWER_NOT_FOUND));

        guardNotCompleted(answer.getLabel());

        String content = request.content() != null ? request.content() : answer.getContent();
        String explanation = request.explanation() != null ? request.explanation() : answer.getExplanation();

        answer.update(content, explanation);
    }

    private StagingProblemResponse toProblemResponse(
            ProblemStaging problem,
            Map<Long, List<OptionStaging>> problemIdToOptions,
            Map<Long, List<AnswerStaging>> problemIdToAnswers
    ) {
        if (problem.getProblemType() == ProblemType.OBJECTIVE) {
            return StagingProblemResponse.objective(problem, problemIdToOptions.getOrDefault(problem.getId(), List.of()));
        }

        List<AnswerStaging> answers = problemIdToAnswers.getOrDefault(problem.getId(), List.of());
        AnswerStaging answer = answers.isEmpty() ? null : answers.get(0);

        return StagingProblemResponse.subjective(problem, answer);
    }

    private void guardNotCompleted(String label) {
        StagingLabel stagingLabel = stagingLabelRepository.findByLabel(label)
                .orElseThrow(() -> new RestApiException(STAGING_LABEL_NOT_FOUND));

        if (stagingLabel.isCompleted()) {
            throw new RestApiException(STAGING_LABEL_ALREADY_COMPLETED);
        }
    }
}
