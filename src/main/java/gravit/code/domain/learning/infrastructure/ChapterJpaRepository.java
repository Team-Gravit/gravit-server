package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.domain.Chapter;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChapterJpaRepository extends JpaRepository<Chapter, Long> {
}
