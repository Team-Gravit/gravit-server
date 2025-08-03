package gravit.code.domain.chapterProgress.domain;

import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;

import java.util.List;
import java.util.Optional;

public interface ChapterProgressRepository {
    Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId);

    boolean existsByChapterIdAndUserId(Long chapterId, Long userId);

    List<ChapterInfoResponse> findAllChaptersWithProgress(Long userId);

    ChapterProgress save(ChapterProgress chapterProgress);

    Optional<ChapterInfo> findChapterInfoByChapterIdAndUserId(Long chapterId, Long userId);
}
