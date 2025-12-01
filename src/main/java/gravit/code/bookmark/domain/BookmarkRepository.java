package gravit.code.bookmark.domain;

import gravit.code.problem.dto.response.ProblemDetail;

import java.util.List;

public interface BookmarkRepository {
    List<ProblemDetail> findBookmarkedProblemDetailByUnitIdAndUserId(
            long unitId,
            long userId
    );
    void save(Bookmark bookmark);
    void deleteByProblemIdAndUserId(
            long problemId,
            long userId
    );
    boolean existsByProblemIdAndUserId(
            long problemId,
            long userId
    );
    int countByUnitIdAndUserId(
            long unitId,
            long userId
    );
}
