package gravit.code.interview.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.service.InterviewAnswerQueryService;
import gravit.code.interview.service.InterviewTranscriptionCommandService;
import gravit.code.interview.service.InterviewTranscriptionService;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import gravit.code.interviewQuestion.service.InterviewQuestionQueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;
import java.util.Set;

@Slf4j
@Facade
@RequiredArgsConstructor
public class InterviewTranscriptionFacade {

    private final InterviewAnswerQueryService interviewAnswerQueryService;
    private final InterviewQuestionQueryService interviewQuestionQueryService;
    private final InterviewTranscriptionService interviewTranscriptionService;
    private final InterviewTranscriptionCommandService interviewTranscriptionCommandService;

    public void transcribe(
            long answerId,
            String audioKey
    ) {
        try {
            InterviewAnswer answer = interviewAnswerQueryService.getById(answerId);

            List<String> conceptNames = interviewQuestionQueryService.getQuestionIdToConcepts(Set.of(answer.getQuestionId()))
                    .getOrDefault(answer.getQuestionId(), List.of()).stream()
                    .map(InterviewQuestionConcept::getName)
                    .toList();

            String transcript = interviewTranscriptionService.transcribe(audioKey, conceptNames);

            interviewTranscriptionCommandService.complete(answerId, transcript);
        } catch (RuntimeException e) {
            log.error("면접 답변 음성 변환 실패 - answerId: {}", answerId, e);
            markTranscriptionFailed(answerId);
        }
    }

    private void markTranscriptionFailed(long answerId) {
        try {
            interviewTranscriptionCommandService.fail(answerId);
        } catch (RuntimeException e) {
            log.error("면접 답변 음성 변환 실패 상태 전이 실패 - answerId: {}", answerId, e);
        }
    }
}
