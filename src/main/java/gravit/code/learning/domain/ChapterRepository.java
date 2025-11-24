package gravit.code.learning.domain;

import gravit.code.learning.dto.response.ChapterSummary;

import java.util.List;
import java.util.Optional;

public interface ChapterRepository {
    Optional<Chapter> findById(long chapterId);
    List<ChapterSummary> findAllChapterSummary();
    Optional<ChapterSummary> findChapterSummaryByChapterId(long chapterId);
    Optional<ChapterSummary> findChapterSummaryByUnitId(long unitId);
    Chapter save(Chapter chapter);
    void saveAll(List<Chapter> chapters);
}
