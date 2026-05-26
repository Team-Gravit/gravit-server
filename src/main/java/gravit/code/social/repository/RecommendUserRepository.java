package gravit.code.social.repository;

import gravit.code.social.dto.internal.RecommendCandidateDto;

import java.util.List;

public interface RecommendUserRepository {

    List<RecommendCandidateDto> findSameSortOrderCandidates(
            long userId,
            int sortOrder,
            int limit
    );

    List<RecommendCandidateDto> findAdjacentSortOrderCandidates(
            long userId,
            int minSortOrder,
            int maxSortOrder,
            int excludeSortOrder,
            int limit
    );
}
