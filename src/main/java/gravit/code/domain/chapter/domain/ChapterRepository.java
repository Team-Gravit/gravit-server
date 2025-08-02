package gravit.code.domain.chapter.domain;

import java.util.Optional;

public interface ChapterRepository {
    Optional<Chapter> findById(Long chapterId);
    Chapter save(Chapter chapter);
    Long getTotalUnitsByChapterId(Long chapterId);
}
