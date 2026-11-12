package gravit.code.support;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interviewFeedback.domain.InterviewStructureLevel;
import gravit.code.interviewFeedback.dto.internal.InterviewConceptJudgmentDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingConceptDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingInputDto;
import gravit.code.interviewFeedback.dto.internal.InterviewGradingJudgmentDto;
import gravit.code.interviewFeedback.infrastructure.InterviewGradingClient;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Function;

// test 프로파일에서 LLM 게이트웨이 없이 채점 파이프라인을 검증하기 위한 스텁.
// 기본 응답은 모든 개념 전달, 오류 없음, 결론 우선, 군더더기 없음(만점)이다
public class StubInterviewGradingClient extends InterviewGradingClient {

    private static final String PERFECT_SUGGESTION = "완벽한 답변이었습니다. 핵심 개념을 빠짐없이 정확하게 설명하셨어요.";
    private static final String EVIDENCE_SUFFIX = " 근거";

    private final List<InterviewGradingInputDto> inputs = new CopyOnWriteArrayList<>();
    private volatile Function<InterviewGradingInputDto, InterviewGradingJudgmentDto> responder = StubInterviewGradingClient::perfectJudgment;

    public StubInterviewGradingClient() {
        super(null);
    }

    @Override
    public InterviewGradingJudgmentDto judge(InterviewGradingInputDto input) {
        inputs.add(input);
        return responder.apply(input);
    }

    public void respondWith(InterviewGradingJudgmentDto judgment) {
        this.responder = input -> judgment;
    }

    public void respondWith(Function<InterviewGradingInputDto, InterviewGradingJudgmentDto> responder) {
        this.responder = responder;
    }

    public void failAlways() {
        this.responder = input -> {
            throw new RestApiException(CustomErrorCode.INTERVIEW_GRADING_FAILED);
        };
    }

    public void reset() {
        inputs.clear();
        this.responder = StubInterviewGradingClient::perfectJudgment;
    }

    public List<InterviewGradingInputDto> inputs() {
        return List.copyOf(inputs);
    }

    public int callCount() {
        return inputs.size();
    }

    public static InterviewGradingJudgmentDto perfectJudgment(InterviewGradingInputDto input) {
        List<InterviewConceptJudgmentDto> conceptJudgments = input.concepts().stream()
                .map(InterviewGradingConceptDto::name)
                .map(name -> new InterviewConceptJudgmentDto(name, name + EVIDENCE_SUFFIX, true))
                .toList();

        return new InterviewGradingJudgmentDto(
                conceptJudgments,
                List.of(),
                InterviewStructureLevel.CONCLUSION_FIRST,
                false,
                0,
                PERFECT_SUGGESTION
        );
    }
}
