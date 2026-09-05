package gravit.code.interviewFeedback.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.service.InterviewAnswerQueryService;
import gravit.code.interview.service.InterviewSessionCommandService;
import gravit.code.interview.service.InterviewSessionQueryService;
import gravit.code.interviewFeedback.dto.internal.InterviewGradedAnswerDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingInputDto;
import gravit.code.interviewFeedback.dto.internal.InterviewScoreDto;
import gravit.code.interviewFeedback.dto.internal.InterviewSessionScoreDto;
import gravit.code.interviewFeedback.policy.InterviewScoringPolicy;
import gravit.code.interviewFeedback.service.InterviewFeedbackCommandService;
import gravit.code.interviewFeedback.service.InterviewGradingService;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import gravit.code.interviewQuestion.service.InterviewQuestionQueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Facade
@RequiredArgsConstructor
public class InterviewGradingFacade {

    private final InterviewSessionCommandService interviewSessionCommandService;
    private final InterviewSessionQueryService interviewSessionQueryService;
    private final InterviewAnswerQueryService interviewAnswerQueryService;
    private final InterviewQuestionQueryService interviewQuestionQueryService;
    private final InterviewGradingService interviewGradingService;
    private final InterviewFeedbackCommandService interviewFeedbackCommandService;

    private final InterviewScoringPolicy interviewScoringPolicy;

    private final TransactionTemplate transactionTemplate;

    public void grade(long sessionId) {
        try {
            // 채점할 세션 조회
            interviewSessionQueryService.getGradingSession(sessionId);

            // 답변 조회
            List<InterviewAnswer> answers = interviewAnswerQueryService.getAllBySessionId(sessionId);

            // 문제 아이디 추출
            Set<Long> questionIds = answers.stream()
                    .map(InterviewAnswer::getQuestionId)
                    .collect(Collectors.toSet());

            // 문제 아이디 - 문제 매핑
            Map<Long, InterviewQuestion> questionIdToQuestion = interviewQuestionQueryService.getQuestionIdToQuestion(questionIds);

            // 문제 아이디 - 문제 개념 매핑
            Map<Long, List<InterviewQuestionConcept>> questionIdToConcepts = interviewQuestionQueryService.getQuestionIdToConcepts(questionIds);

            // 문항별 판정과 점수 계산 (무응답은 AI 호출 없이 0점)
            List<InterviewGradedAnswerDto> gradedAnswers = gradeAnswers(answers, questionIdToQuestion, questionIdToConcepts);

            // 문항 점수 추출
            List<InterviewScoreDto> scores = gradedAnswers.stream()
                    .map(InterviewGradedAnswerDto::score)
                    .toList();

            // 세션 점수 합산 (정확도 합, 전달력 합)
            InterviewSessionScoreDto sessionScore = interviewScoringPolicy.aggregate(scores);

            // 피드백 5건과 세션 점수를 단일 트랜잭션으로 저장, COMPLETED 전이
            save(sessionId, gradedAnswers, sessionScore);
        } catch (RuntimeException e) {
            log.error("면접 채점 실패 - sessionId: {}", sessionId, e);
            markGradingFailed(sessionId);
        }
    }

    private List<InterviewGradedAnswerDto> gradeAnswers(
            List<InterviewAnswer> answers,
            Map<Long, InterviewQuestion> questionIdToQuestion,
            Map<Long, List<InterviewQuestionConcept>> questionIdToConcepts
    ) {
        List<InterviewGradedAnswerDto> gradedAnswers = new ArrayList<>();

        for (InterviewAnswer answer : answers) {
            InterviewQuestion question = questionIdToQuestion.get(answer.getQuestionId());
            List<InterviewQuestionConcept> concepts = questionIdToConcepts.getOrDefault(answer.getQuestionId(), List.of());

            gradedAnswers.add(gradeAnswer(answer, question, concepts));
        }

        return gradedAnswers;
    }

    private InterviewGradedAnswerDto gradeAnswer(
            InterviewAnswer answer,
            InterviewQuestion question,
            List<InterviewQuestionConcept> concepts
    ) {
        if (!answer.isAnswered()) {
            return InterviewGradedAnswerDto.of(answer.getId(), InterviewScoreDto.noResponse());
        }

        InterviewGradingJudgmentDto judgment = interviewGradingService.judge(
                InterviewGradingInputDto.of(question, concepts, answer.getContent())
        );

        return InterviewGradedAnswerDto.of(answer.getId(), interviewScoringPolicy.score(judgment, concepts));
    }

    private void save(
            long sessionId,
            List<InterviewGradedAnswerDto> gradedAnswers,
            InterviewSessionScoreDto sessionScore
    ) {
        transactionTemplate.executeWithoutResult(status -> {
            interviewFeedbackCommandService.saveAll(gradedAnswers);
            interviewSessionCommandService.completeGrading(
                    sessionId,
                    sessionScore.accuracyScore(),
                    sessionScore.deliveryScore()
            );
        });
    }

    private void markGradingFailed(long sessionId) {
        try {
            interviewSessionCommandService.failGrading(sessionId);
        } catch (RuntimeException e) {
            log.error("면접 채점 실패 상태 전이 실패 - sessionId: {}", sessionId, e);
        }
    }
}
