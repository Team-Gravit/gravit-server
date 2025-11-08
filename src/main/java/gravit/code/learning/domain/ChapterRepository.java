package gravit.code.learning.domain;

import java.util.List;
import java.util.Optional;

public interface ChapterRepository {
    Optional<Chapter> findById(Long chapterId);
    Chapter save(Chapter chapter);
    void saveAll(List<Chapter> chapters);
}
