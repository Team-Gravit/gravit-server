package gravit.code.chapterProgress.service;

import gravit.code.chapterProgress.dto.response.ChapterInfoResponse;
import gravit.code.chapterProgress.domain.ChapterProgress;
import gravit.code.chapterProgress.repository.ChapterProgressRepository;
import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChapterProgressService {

    private final ChapterProgressRepository chapterProgressRepository;

    public void createChapterProgress(Long userId, Long chapterId){
        if (!chapterProgressRepository.existsByChapterIdAndUserId(chapterId,userId)){
            Long totalUnits = chapterProgressRepository.getTotalUnitsByChapterId(chapterId);
            ChapterProgress chapterProgress = ChapterProgress.create(totalUnits, userId, chapterId);
            chapterProgressRepository.save(chapterProgress);
        }
    }

    public void updateChapterProgress(Long userId, Long chapterId){
        ChapterProgress chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId,userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_PROGRESS_NOT_FOUND));

        chapterProgress.updateCompletedUnits();
    }

    public List<ChapterInfoResponse> findChaptersWithProgressByUserId(Long userId){
        return chapterProgressRepository.findAllChapterInfoByUserId(userId);
    }
}
