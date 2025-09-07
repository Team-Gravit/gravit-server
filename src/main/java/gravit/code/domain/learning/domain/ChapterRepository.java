package gravit.code.domain.learning.domain;

import java.util.Optional;

public interface ChapterRepository {
    Optional<Chapter> findById(Long chapterId);
    Chapter save(Chapter chapter);
}
