package gravit.code.domain.learning.infrastructure;

import gravit.code.domain.learning.domain.Chapter;
import gravit.code.domain.learning.domain.ChapterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ChapterRepositoryImpl implements ChapterRepository {

    private final ChapterJpaRepository chapterJpaRepository;

    @Override
    public Optional<Chapter> findById(Long chapterId){
        return chapterJpaRepository.findById(chapterId);
    }
    @Override
    public Chapter save(Chapter chapter) {
        return chapterJpaRepository.save(chapter);
    }
}
