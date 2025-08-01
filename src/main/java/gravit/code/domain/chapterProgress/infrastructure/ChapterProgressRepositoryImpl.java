package gravit.code.domain.chapterProgress.infrastructure;

import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterSummaryResponse;
import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.repository.query.Param;
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
    public Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId){
        return chapterProgressJpaRepository.findByChapterIdAndUserId(chapterId,userId);
    }

    @Override
    public List<ChapterProgressDetailResponse> findAllChapterProgressDetailByUserId(@Param("userId") Long userId){
        return chapterProgressJpaRepository.findAllChapterProgressDetailByUserId(userId);
    }

    @Override
    public Optional<ChapterSummaryResponse> findChapterSummaryByChapterIdAndUserId(Long chapterId, Long userId){
        return chapterProgressJpaRepository.findChapterSummaryByChapterIdAndUserId(chapterId, userId);
    }

}
