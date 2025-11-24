package gravit.code.chapter.domain;

import gravit.code.chapter.dto.response.ChapterSummary;

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
