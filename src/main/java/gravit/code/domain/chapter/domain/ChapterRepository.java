package gravit.code.domain.chapter.domain;

import gravit.code.domain.learning.dto.response.RecentLearningInfo;

import java.util.Optional;

public interface ChapterRepository {
    Optional<RecentLearningInfo> findRecentLearningChapterByProblemId(Long userId);
}
