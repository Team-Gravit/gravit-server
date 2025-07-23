package gravit.code.domain.chapter.infrastructure;

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
    public Optional<RecentLearningInfo> findRecentLearningChapterByProblemId(Long userId) {
        return chapterJpaRepository.findRecentLearningChapterByProblemId(userId);
    }

}
