package gravit.code.admin.service;

import gravit.code.admin.domain.audit.AuditAction;
import gravit.code.admin.domain.staging.AnswerStaging;
import gravit.code.admin.domain.staging.LabelStatus;
import gravit.code.admin.domain.staging.LessonStaging;
import gravit.code.admin.domain.staging.OptionStaging;
import gravit.code.admin.domain.staging.ProblemStaging;
import gravit.code.admin.domain.staging.StagingLabel;
import gravit.code.admin.repository.AnswerStagingRepository;
import gravit.code.admin.repository.LessonStagingRepository;
import gravit.code.admin.repository.OptionStagingRepository;
import gravit.code.admin.repository.ProblemStagingRepository;
import gravit.code.admin.repository.StagingLabelRepository;
import gravit.code.admin.support.AuditLogRecorder;
import gravit.code.answer.domain.Answer;
import gravit.code.answer.repository.AnswerRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.domain.Lesson;
import gravit.code.lesson.repository.LessonRepository;
import gravit.code.option.domain.Option;
import gravit.code.option.repository.OptionRepository;
import gravit.code.problem.domain.Problem;
import gravit.code.problem.domain.ProblemType;
import gravit.code.problem.repository.ProblemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_INVALID_STRUCTURE;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_LABEL_ALREADY_COMPLETED;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_LABEL_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_LESSON_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.STAGING_STATUS_INVALID;

@Service
@RequiredArgsConstructor
public class AdminStagingPromoteService {

    private static final int EXPECTED_PROBLEM_COUNT = 6;
    private static final int EXPECTED_OBJECTIVE_COUNT = 4;
    private static final int EXPECTED_SUBJECTIVE_COUNT = 2;
    private static final int EXPECTED_OPTION_COUNT = 4;

    private final StagingLabelRepository stagingLabelRepository;
    private final LessonStagingRepository lessonStagingRepository;
    private final ProblemStagingRepository problemStagingRepository;
    private final OptionStagingRepository optionStagingRepository;
    private final AnswerStagingRepository answerStagingRepository;
    private final LessonRepository lessonRepository;
    private final ProblemRepository problemRepository;
    private final OptionRepository optionRepository;
    private final AnswerRepository answerRepository;

    private final AuditLogRecorder auditLogRecorder;

    @Transactional
    public void promote(
            long adminId,
            String label,
            LabelStatus targetStatus
    ) {
        if (targetStatus != LabelStatus.COMPLETED) {
            throw new RestApiException(STAGING_STATUS_INVALID);
        }

        StagingLabel stagingLabel = stagingLabelRepository.findByLabel(label)
                .orElseThrow(() -> new RestApiException(STAGING_LABEL_NOT_FOUND));

        if (stagingLabel.isCompleted()) {
            throw new RestApiException(STAGING_LABEL_ALREADY_COMPLETED);
        }

        LessonStaging lessonStaging = lessonStagingRepository.findByLabel(label)
                .orElseThrow(() -> new RestApiException(STAGING_LESSON_NOT_FOUND));

        List<ProblemStaging> problemStagings = problemStagingRepository.findByLabelOrderById(label);
        List<OptionStaging> optionStagings = optionStagingRepository.findByLabelOrderById(label);
        List<AnswerStaging> answerStagings = answerStagingRepository.findByLabelOrderById(label);

        validateStructure(problemStagings, optionStagings, answerStagings);

        Lesson prodLesson = lessonRepository.save(Lesson.create(lessonStaging.getTitle(), lessonStaging.getUnitId()));

        Map<Long, Long> stagingProblemIdToProblemId = new HashMap<>();
        for (ProblemStaging problemStaging : problemStagings) {
            Problem prodProblem = problemRepository.save(Problem.create(
                    problemStaging.getProblemType(),
                    problemStaging.getInstruction(),
                    problemStaging.getContent(),
                    prodLesson.getId()));
            stagingProblemIdToProblemId.put(problemStaging.getId(), prodProblem.getId());
        }

        for (OptionStaging optionStaging : optionStagings) {
            long prodProblemId = stagingProblemIdToProblemId.get(optionStaging.getProblemId());
            optionRepository.save(Option.create(
                    optionStaging.getContent(),
                    optionStaging.getExplanation(),
                    optionStaging.isAnswer(),
                    prodProblemId));
        }

        for (AnswerStaging answerStaging : answerStagings) {
            long prodProblemId = stagingProblemIdToProblemId.get(answerStaging.getProblemId());
            answerRepository.save(Answer.create(
                    answerStaging.getContent(),
                    answerStaging.getExplanation(),
                    prodProblemId));
        }

        stagingLabel.complete();

        auditLogRecorder.record(adminId, AuditAction.STAGING_PROMOTE, label, null, LabelStatus.COMPLETED.name());
    }

    private void validateStructure(
            List<ProblemStaging> problems,
            List<OptionStaging> options,
            List<AnswerStaging> answers
    ) {
        if (problems.size() != EXPECTED_PROBLEM_COUNT) {
            throw new RestApiException(STAGING_INVALID_STRUCTURE);
        }

        long objectiveCount = problems.stream().filter(p -> p.getProblemType() == ProblemType.OBJECTIVE).count();
        long subjectiveCount = problems.stream().filter(p -> p.getProblemType() == ProblemType.SUBJECTIVE).count();

        if (objectiveCount != EXPECTED_OBJECTIVE_COUNT || subjectiveCount != EXPECTED_SUBJECTIVE_COUNT) {
            throw new RestApiException(STAGING_INVALID_STRUCTURE);
        }

        Set<Long> problemIds = problems.stream()
                .map(ProblemStaging::getId)
                .collect(Collectors.toSet());

        boolean optionsReferenceValid = options.stream()
                .allMatch(option -> problemIds.contains(option.getProblemId()));
        boolean answersReferenceValid = answers.stream()
                .allMatch(answer -> answer.getProblemId() != null && problemIds.contains(answer.getProblemId()));

        if (!optionsReferenceValid || !answersReferenceValid) {
            throw new RestApiException(STAGING_INVALID_STRUCTURE);
        }

        Map<Long, List<OptionStaging>> problemIdToOptions = options.stream()
                .collect(Collectors.groupingBy(OptionStaging::getProblemId));

        Map<Long, List<AnswerStaging>> problemIdToAnswers = answers.stream()
                .filter(answer -> answer.getProblemId() != null)
                .collect(Collectors.groupingBy(AnswerStaging::getProblemId));

        for (ProblemStaging problem : problems) {
            if (problem.getProblemType() == ProblemType.OBJECTIVE) {
                List<OptionStaging> problemOptions = problemIdToOptions.getOrDefault(problem.getId(), List.of());
                long answerOptionCount = problemOptions.stream().filter(OptionStaging::isAnswer).count();

                if (problemOptions.size() != EXPECTED_OPTION_COUNT || answerOptionCount != 1) {
                    throw new RestApiException(STAGING_INVALID_STRUCTURE);
                }

            } else {
                List<AnswerStaging> problemAnswers = problemIdToAnswers.getOrDefault(problem.getId(), List.of());

                if (problemAnswers.size() != 1) {
                    throw new RestApiException(STAGING_INVALID_STRUCTURE);
                }
            }
        }
    }
}
