package gravit.code.domain.chapter.domain;

import gravit.code.domain.learning.dto.response.RecentLearningInfo;

import java.util.Optional;

public interface ChapterRepository {
    Optional<RecentLearningInfo> findRecentLearningChapter(Long userId);
    Chapter save(Chapter chapter);
    Long getTotalUnitsByChapterId(Long chapterId);
}
