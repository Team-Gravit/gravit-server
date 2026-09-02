package gravit.code.interviewFeedback.infrastructure;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgment;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingSource;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class InterviewGradingClient {

    private static final String SYSTEM_PROMPT = """
            당신은 IT 기업의 기술 면접관이다. 면접 질문, 핵심 개념 목록, 지원자의 답변을 받아 아래 규칙대로 판정한다.

            판정 규칙:
            1. 핵심 개념 목록의 각 개념에 대해 답변이 그 개념을 전달했는지(covered) 판정한다.
               - 전달했다면 답변 원문에서 근거가 되는 구간을 그대로 인용해 quote에 담고, missingFeedbackText는 null로 둔다.
               - 누락했다면 quote는 null로 두고, 무엇이 빠졌고 어떻게 보완하면 되는지 안내 문구를 missingFeedbackText에 담는다.
            2. 답변에서 사실과 다르게 말한 구간이 있으면 wrongStatements에 담는다.
               quotedText에는 답변 원문 구간을 그대로 인용하고, correctionText에는 올바른 설명을 담는다. 없으면 빈 배열로 둔다.
            3. 결론(질문에 대한 핵심 답)을 먼저 말하고 부연했는지 conclusionFirst로 판정한다.
            4. 질문과 무관하거나 불필요하게 반복된 군더더기 발화의 개수를 irrelevantStatementCount에 담는다. 없으면 0으로 둔다.
            5. 답변 전체에서 가장 중요한 개선 제안 하나를 improvementSuggestion에 담는다.

            공통 규칙:
            - conceptJudgments의 conceptName은 핵심 개념 목록의 개념명을 그대로 쓰고, 목록의 모든 개념을 빠짐없이 포함한다.
            - 인용(quote, quotedText)은 답변 원문을 수정 없이 그대로 옮긴다.
            - 개념 목록의 [ESSENTIAL]은 필수 개념, [SUPPLEMENTARY]는 보조 개념 표시다.
            - 모든 생성 문구는 한국어로 작성한다.
            """;

    private static final String USER_MESSAGE_FORMAT = """
            [질문]
            %s

            [핵심 개념 목록]
            %s

            [답변]
            %s
            """;

    private static final String CONCEPT_LINE_FORMAT = "- [%s] %s";

    private final ChatClient chatClient;

    public InterviewGradingJudgment judge(InterviewGradingSource source) {
        try {
            return chatClient.prompt()
                    .system(SYSTEM_PROMPT)
                    .user(buildUserMessage(source))
                    .call()
                    .entity(InterviewGradingJudgment.class);
        } catch (RuntimeException e) {
            log.error("면접 답변 채점 판정 호출 실패", e);
            throw new RestApiException(CustomErrorCode.INTERVIEW_GRADING_FAILED);
        }
    }

    private String buildUserMessage(InterviewGradingSource source) {
        String conceptLines = source.concepts().stream()
                .map(concept -> CONCEPT_LINE_FORMAT.formatted(concept.type().name(), concept.name()))
                .collect(Collectors.joining("\n"));

        return USER_MESSAGE_FORMAT.formatted(source.question(), conceptLines, source.answer());
    }
}
