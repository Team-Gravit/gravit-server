package gravit.code.chapterProgress.repository;

import gravit.code.chapterProgress.domain.ChapterProgress;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChapterProgressRepository extends JpaRepository<ChapterProgress,Long> {
    ChapterProgress findByChapterIdAndUserId(Long chapterId, Long userId);
}
