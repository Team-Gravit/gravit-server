package gravit.code.progress.infrastructure;

import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.domain.ChapterProgressRepository;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.ChapterSummaryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ChapterProgressRepositoryImpl implements ChapterProgressRepository {

    private final ChapterProgressJpaRepository chapterProgressJpaRepository;

    @Override
    public ChapterProgress save(ChapterProgress chapterProgress){
        return chapterProgressJpaRepository.save(chapterProgress);
    }
    @Override
    public Optional<ChapterProgress> findByChapterIdAndUserId(long chapterId, long userId){
        return chapterProgressJpaRepository.findByChapterIdAndUserId(chapterId,userId);
    }

    @Override
    public List<ChapterProgressDetailResponse> findAllChapterProgressDetailByUserId(long userId){
        return chapterProgressJpaRepository.findAllChapterProgressDetailByUserId(userId);
    }

    @Override
    public Optional<ChapterSummaryResponse> findChapterSummaryByChapterIdAndUserId(long chapterId, long userId){
        return chapterProgressJpaRepository.findChapterSummaryByChapterIdAndUserId(chapterId, userId);
    }

}
