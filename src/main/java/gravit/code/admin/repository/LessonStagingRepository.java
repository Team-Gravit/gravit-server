package gravit.code.admin.repository;

import gravit.code.admin.domain.staging.LessonStaging;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LessonStagingRepository extends JpaRepository<LessonStaging, Long> {
    Optional<LessonStaging> findByLabel(String label);
}
