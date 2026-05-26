package gravit.code.social.service;

import gravit.code.social.dto.internal.RecommendCandidateDto;
import gravit.code.social.repository.RecommendUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RecommendUserService {

    private static final int MAX_RECOMMEND = 8;
    private static final int MIN_RECOMMEND_THRESHOLD = 5;

    private final RecommendUserRepository recommendUserRepository;

    @Transactional(readOnly = true)
    public List<RecommendCandidateDto> findCandidates(
            long userId,
            int mainSortOrder
    ) {
        List<RecommendCandidateDto> candidates = new ArrayList<>(
                recommendUserRepository.findSameSortOrderCandidates(userId, mainSortOrder, MAX_RECOMMEND)
        );

        if (candidates.size() < MIN_RECOMMEND_THRESHOLD) {
            int remaining = MAX_RECOMMEND - candidates.size();
            List<RecommendCandidateDto> additional = recommendUserRepository.findAdjacentSortOrderCandidates(
                    userId,
                    Math.max(1, mainSortOrder - 1),
                    mainSortOrder + 1,
                    mainSortOrder,
                    remaining
            );
            candidates.addAll(additional);
        }

        return candidates;
    }
}
