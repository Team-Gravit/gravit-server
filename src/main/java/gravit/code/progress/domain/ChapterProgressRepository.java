package gravit.code.progress.domain;

import gravit.code.progress.dto.response.ChapterProgressDetailResponse;

import java.util.List;
import java.util.Optional;

public interface ChapterProgressRepository {
    ChapterProgress save(ChapterProgress chapterProgress);
    Optional<ChapterProgress> findByChapterIdAndUserId(
            long chapterId,
            long userId
    );
    List<ChapterProgressDetailResponse> findAllChapterProgressDetailByUserId(long userId);
    void saveAll(List<ChapterProgress> chapterProgresses);
}
