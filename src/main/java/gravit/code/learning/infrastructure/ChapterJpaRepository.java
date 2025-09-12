package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Chapter;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChapterJpaRepository extends JpaRepository<Chapter, Long> {
}
