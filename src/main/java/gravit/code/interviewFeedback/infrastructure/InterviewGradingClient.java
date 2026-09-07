package gravit.code.interviewFeedback.infrastructure;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingConceptDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingInputDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class InterviewGradingClient {

    private static final Resource SYSTEM_PROMPT = new ClassPathResource("prompts/interview-grading-system.st");
    private static final Resource USER_PROMPT = new ClassPathResource("prompts/interview-grading-user.st");
    private static final String CONCEPT_LINE_FORMAT = "- [%s] %s";
    private static final String CONCEPT_LINE_SEPARATOR = "\n";

    private final ChatClient chatClient;

    public InterviewGradingJudgmentDto judge(InterviewGradingInputDto input) {
        try {
            return chatClient.prompt()
                    .system(SYSTEM_PROMPT)
                    .user(user -> user.text(USER_PROMPT)
                            .param("questionContent", input.questionContent())
                            .param("modelAnswer", input.modelAnswer())
                            .param("concepts", buildConceptLines(input.concepts()))
                            .param("answerContent", input.answerContent()))
                    .call()
                    .entity(InterviewGradingJudgmentDto.class);
        } catch (RuntimeException e) {
            log.error("면접 답변 채점 판정 호출 실패", e);
            throw new RestApiException(CustomErrorCode.INTERVIEW_GRADING_FAILED);
        }
    }

    private String buildConceptLines(List<InterviewGradingConceptDto> concepts) {
        return concepts.stream()
                .map(concept -> CONCEPT_LINE_FORMAT.formatted(concept.type().name(), concept.name()))
                .collect(Collectors.joining(CONCEPT_LINE_SEPARATOR));
    }
}
