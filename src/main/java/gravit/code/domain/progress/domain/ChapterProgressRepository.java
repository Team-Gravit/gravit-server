package gravit.code.domain.progress.domain;

import gravit.code.domain.progress.dto.response.ChapterSummaryResponse;
import gravit.code.domain.progress.dto.response.ChapterProgressDetailResponse;

import java.util.List;
import java.util.Optional;

public interface ChapterProgressRepository {

    ChapterProgress save(ChapterProgress chapterProgress);

    Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId);

    List<ChapterProgressDetailResponse> findAllChapterProgressDetailByUserId(Long userId);

    Optional<ChapterSummaryResponse> findChapterSummaryByChapterIdAndUserId(Long chapterId, Long userId);
}
