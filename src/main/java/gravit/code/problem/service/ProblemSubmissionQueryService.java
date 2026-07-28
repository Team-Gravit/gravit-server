package gravit.code.problem.service;

import gravit.code.learning.dto.internal.WeakUnitStatDto;
import gravit.code.learning.dto.response.WeakConceptResponse;
import gravit.code.problem.repository.ProblemSubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProblemSubmissionQueryService {

    private static final int WEAK_UNITS_LIMIT = 7;

    private final ProblemSubmissionRepository problemSubmissionRepository;

    @Transactional(readOnly = true)
    public List<WeakConceptResponse> getWeakConcepts(long userId) {
        List<WeakUnitStatDto> weakUnitStats = problemSubmissionRepository.findWeakUnitsByUserId(
                userId, PageRequest.of(0, WEAK_UNITS_LIMIT)
        );

        List<WeakConceptResponse> response = new ArrayList<>();

        for(int i = 0; i < weakUnitStats.size(); i++) {
            response.add(WeakConceptResponse.of(
                    i + 1, weakUnitStats.get(i)
            ));
        }

        return response;
    }
}
