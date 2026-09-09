package gravit.code.interview.policy;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewStack;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.domain.InterviewTopicKind;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolDto;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class InterviewQuestionAllocationPolicy {

    private static final Map<Integer, List<Integer>> TOPIC_COUNT_TO_CS_QUOTAS = Map.of(
            1, List.of(5),
            2, List.of(3, 2),
            3, List.of(2, 2, 1),
            4, List.of(2, 1, 1, 1),
            5, List.of(1, 1, 1, 1, 1)
    );

    private static final int JOB_COMMON_QUOTA = 1;
    private static final int JOB_LANGUAGE_QUOTA = 2;
    private static final int JOB_FRAMEWORK_QUOTA = 2;
    private static final int MAX_CS_TOPIC_COUNT = 5;

    public Map<InterviewTopic, Integer> allocate(
            InterviewMode mode,
            InterviewStack stack,
            List<InterviewTopic> topics
    ) {
        if (mode == InterviewMode.COMMON_CS) {
            return allocateCommonCs(stack, topics);
        }

        return allocateJobSpecific(stack, topics);
    }

    public List<Long> select(
            InterviewMode mode,
            Map<InterviewTopic, Integer> topicToQuota,
            List<InterviewQuestionPoolDto> pool
    ) {
        Map<InterviewTopic, List<Long>> topicToQuestionIds = pickByQuota(topicToQuota, pool);

        return orderByMode(mode, topicToQuestionIds);
    }

    private Map<InterviewTopic, Integer> allocateCommonCs(
            InterviewStack stack,
            List<InterviewTopic> topics
    ) {
        if (stack != null) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_STACK_NOT_ALLOWED);
        }
        if (topics == null || topics.isEmpty()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_TOPIC_REQUIRED);
        }
        validateCsTopics(topics);

        List<InterviewTopic> shuffledTopics = new ArrayList<>(topics);
        Collections.shuffle(shuffledTopics);

        List<Integer> quotas = TOPIC_COUNT_TO_CS_QUOTAS.get(shuffledTopics.size());

        Map<InterviewTopic, Integer> topicToQuota = new LinkedHashMap<>();
        for (int index = 0; index < shuffledTopics.size(); index++) {
            topicToQuota.put(shuffledTopics.get(index), quotas.get(index));
        }

        return topicToQuota;
    }

    private Map<InterviewTopic, Integer> allocateJobSpecific(
            InterviewStack stack,
            List<InterviewTopic> topics
    ) {
        if (stack == null) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_STACK_REQUIRED);
        }
        if (topics != null && !topics.isEmpty()) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_TOPIC_NOT_ALLOWED);
        }

        Map<InterviewTopic, Integer> topicToQuota = new LinkedHashMap<>();
        topicToQuota.put(stack.getCommonTopic(), JOB_COMMON_QUOTA);
        topicToQuota.put(stack.getLanguageTopic(), JOB_LANGUAGE_QUOTA);
        topicToQuota.put(stack.getFrameworkTopic(), JOB_FRAMEWORK_QUOTA);

        return topicToQuota;
    }

    private void validateCsTopics(List<InterviewTopic> topics) {
        Set<InterviewTopic> distinctTopics = Set.copyOf(topics);

        boolean hasDuplicate = distinctTopics.size() != topics.size();
        boolean exceedsLimit = topics.size() > MAX_CS_TOPIC_COUNT;
        boolean hasNonCsTopic = topics.stream()
                .anyMatch(topic -> topic.getKind() != InterviewTopicKind.CS);

        if (hasDuplicate || exceedsLimit || hasNonCsTopic) {
            throw new RestApiException(CustomErrorCode.INTERVIEW_TOPIC_INVALID);
        }
    }

    private Map<InterviewTopic, List<Long>> pickByQuota(
            Map<InterviewTopic, Integer> topicToQuota,
            List<InterviewQuestionPoolDto> pool
    ) {
        Map<InterviewTopic, List<Long>> topicToCandidates = pool.stream()
                .collect(Collectors.groupingBy(
                        InterviewQuestionPoolDto::topic,
                        LinkedHashMap::new,
                        Collectors.mapping(InterviewQuestionPoolDto::questionId, Collectors.toList())
                ));

        Map<InterviewTopic, List<Long>> topicToQuestionIds = new LinkedHashMap<>();
        for (Map.Entry<InterviewTopic, Integer> entry : topicToQuota.entrySet()) {
            InterviewTopic topic = entry.getKey();
            int quota = entry.getValue();

            List<Long> candidates = new ArrayList<>(topicToCandidates.getOrDefault(topic, List.of()));
            if (candidates.size() < quota) {
                throw new RestApiException(CustomErrorCode.INTERVIEW_QUESTION_POOL_INSUFFICIENT);
            }
            Collections.shuffle(candidates);

            topicToQuestionIds.put(topic, List.copyOf(candidates.subList(0, quota)));
        }

        return topicToQuestionIds;
    }

    private List<Long> orderByMode(
            InterviewMode mode,
            Map<InterviewTopic, List<Long>> topicToQuestionIds
    ) {
        List<Long> orderedQuestionIds = topicToQuestionIds.values().stream()
                .flatMap(List::stream)
                .collect(Collectors.toCollection(ArrayList::new));

        if (mode == InterviewMode.COMMON_CS) {
            Collections.shuffle(orderedQuestionIds);
        }

        return List.copyOf(orderedQuestionIds);
    }
}
