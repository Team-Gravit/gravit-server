package gravit.code.interviewQuestion.service;

import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.domain.InterviewTopicKind;
import gravit.code.interviewQuestion.dto.response.InterviewTopicResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InterviewTopicQueryService {

    public List<InterviewTopicResponse> getCsTopics() {
        return Arrays.stream(InterviewTopic.values())
                .filter(topic -> topic.getKind() == InterviewTopicKind.CS)
                .map(InterviewTopicResponse::from)
                .toList();
    }
}
