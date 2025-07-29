package gravit.code.domain.chapter.infrastructure;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.domain.ChapterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class ChapterRepositoryImpl implements ChapterRepository {

    private final ChapterJpaRepository chapterJpaRepository;

    @Override
    public Chapter save(Chapter chapter) {
        return chapterJpaRepository.save(chapter);
    }

    @Override
    public Long getTotalUnitsByChapterId(Long chapterId) {
        return chapterJpaRepository.getTotalUnitsByChapterId(chapterId);
    }

}
