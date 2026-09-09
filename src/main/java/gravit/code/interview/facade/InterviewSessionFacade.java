package gravit.code.interview.facade;

import gravit.code.global.annotation.Facade;
import gravit.code.interview.dto.internal.InterviewSessionCreateDto;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewSessionCreateResponse;
import gravit.code.interview.policy.InterviewQuestionAllocationPolicy;
import gravit.code.interview.service.InterviewSessionCommandService;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolDto;
import gravit.code.interviewQuestion.service.InterviewQuestionQueryService;
import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.Map;

@Facade
@RequiredArgsConstructor
public class InterviewSessionFacade {

    private final InterviewQuestionAllocationPolicy interviewQuestionAllocationPolicy;

    private final InterviewQuestionQueryService interviewQuestionQueryService;
    private final InterviewSessionCommandService interviewSessionCommandService;

    public InterviewSessionCreateResponse create(
            long userId,
            InterviewSessionCreateRequest request
    ) {
        Map<InterviewTopic, Integer> topicToQuota = interviewQuestionAllocationPolicy.allocate(
                request.mode(), request.stack(), request.topics());

        List<InterviewQuestionPoolDto> pool = interviewQuestionQueryService.getPool(
                topicToQuota.keySet(), request.difficulty());

        List<Long> orderedQuestionIds = interviewQuestionAllocationPolicy.select(
                request.mode(), topicToQuota, pool);

        long sessionId = interviewSessionCommandService.create(
                userId, InterviewSessionCreateDto.of(request, topicToQuota.keySet(), orderedQuestionIds));

        return InterviewSessionCreateResponse.from(sessionId);
    }
}
