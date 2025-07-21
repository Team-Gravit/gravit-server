package gravit.code.chapterProgress.repository;

import gravit.code.chapterProgress.domain.ChapterProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ChapterProgressRepository extends JpaRepository<ChapterProgress,Long> {
    Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId);
}
