package gravit.code.domain.chapter.infrastructure;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.learning.dto.response.RecentLearningInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ChapterRepositoryImpl implements ChapterRepository {

    private final ChapterJpaRepository chapterJpaRepository;

    @Override
    public Optional<RecentLearningInfo> findRecentLearningChapter(Long userId) {
        return chapterJpaRepository.findRecentLearningChapter(userId);
    }

    @Override
    public Chapter save(Chapter chapter) {
        return chapterJpaRepository.save(chapter);
    }

    @Override
    public Long getTotalUnitsByChapterId(Long chapterId) {
        return chapterJpaRepository.getTotalUnitsByChapterId(chapterId);
    }

}
