package gravit.code.interviewQuestion.service;

import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewQuestionConcept;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.dto.internal.InterviewQuestionPoolDto;
import gravit.code.interviewQuestion.repository.InterviewQuestionConceptRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InterviewQuestionQueryService {

    private final InterviewQuestionRepository interviewQuestionRepository;
    private final InterviewQuestionConceptRepository interviewQuestionConceptRepository;

    @Transactional(readOnly = true)
    public List<InterviewQuestionPoolDto> getPool(
            Collection<InterviewTopic> topics,
            InterviewDifficulty difficulty
    ) {
        return interviewQuestionRepository.findPoolByTopicsAndDifficulty(topics, difficulty);
    }

    @Transactional(readOnly = true)
    public Map<Long, InterviewQuestion> getQuestionIdToQuestion(Collection<Long> questionIds) {
        return interviewQuestionRepository.findAllById(questionIds).stream()
                .collect(Collectors.toMap(InterviewQuestion::getId, Function.identity()));
    }

    @Transactional(readOnly = true)
    public Map<Long, List<InterviewQuestionConcept>> getQuestionIdToConcepts(Collection<Long> questionIds) {
        return interviewQuestionConceptRepository.findAllByQuestionIds(questionIds).stream()
                .collect(Collectors.groupingBy(
                        InterviewQuestionConcept::getQuestionId,
                        LinkedHashMap::new,
                        Collectors.toList()
                ));
    }
}
