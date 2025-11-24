package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.ChapterRepository;
import gravit.code.learning.dto.response.ChapterSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ChapterRepositoryImpl implements ChapterRepository {

    private final ChapterJpaRepository chapterJpaRepository;

    @Override
    public Optional<Chapter> findById(long chapterId){
        return chapterJpaRepository.findById(chapterId);
    }

    @Override
    public List<ChapterSummary> findAllChapterSummary(){
        return chapterJpaRepository.findAllChapterSummary();
    }

    @Override
    public Optional<ChapterSummary> findChapterSummaryByChapterId(long chapterId) {
        return chapterJpaRepository.findChapterSummaryByChapterId(chapterId);
    }

    @Override
    public Optional<ChapterSummary> findChapterSummaryByUnitId(long unitId) {
        return chapterJpaRepository.findChapterSummaryByUnitId(unitId);
    }

    @Override
    public Chapter save(Chapter chapter) {
        return chapterJpaRepository.save(chapter);
    }

    @Override
    public void saveAll(List<Chapter> chapters){
        chapterJpaRepository.saveAll(chapters);
    }
}
