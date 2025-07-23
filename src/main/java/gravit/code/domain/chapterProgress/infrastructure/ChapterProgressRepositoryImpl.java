package gravit.code.domain.chapterProgress.infrastructure;

import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;
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
    public Optional<ChapterProgress> findByChapterIdAndUserId(Long chapterId, Long userId){
        return chapterProgressJpaRepository.findByChapterIdAndUserId(chapterId,userId);
    }

    @Override
    public boolean existsByChapterIdAndUserId(Long chapterId, Long userId){
        return chapterProgressJpaRepository.existsByChapterIdAndUserId(chapterId,userId);
    }

    @Override
    public Long getTotalUnitsByChapterId(Long chapterId){
        return chapterProgressJpaRepository.getTotalUnitsByChapterId(chapterId);
    }

    @Override
    public List<ChapterInfoResponse> findAllChaptersWithProgress(@Param("userId") Long userId){
        return chapterProgressJpaRepository.findAllChapterInfoByUserId(userId);
    }

    @Override
    public ChapterProgress save(ChapterProgress chapterProgress){
        return chapterProgressJpaRepository.save(chapterProgress);
    }

}
