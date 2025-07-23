package gravit.code.domain.chapterProgress.domain;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChapterProgressRepository {
    Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId);

    boolean existsByChapterIdAndUserId(Long chapterId, Long userId);

    Long getTotalUnitsByChapterId(Long chapterId);

    List<ChapterInfoResponse> findAllChaptersWithProgress(@Param("userId") Long userId);

    ChapterProgress save(ChapterProgress chapterProgress);
}
