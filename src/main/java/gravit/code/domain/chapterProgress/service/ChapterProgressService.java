package gravit.code.domain.chapterProgress.service;

import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;
import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChapterProgressService {

    private final ChapterProgressRepository chapterProgressRepository;
    private final ChapterRepository chapterRepository;

    public void createChapterProgress(Long userId, Long chapterId){
        if (!chapterProgressRepository.existsByChapterIdAndUserId(chapterId, userId)){
            Long totalUnits = chapterRepository.getTotalUnitsByChapterId(chapterId);
            ChapterProgress chapterProgress = ChapterProgress.create(totalUnits, userId, chapterId);
            chapterProgressRepository.save(chapterProgress);
        }
    }

    public void updateChapterProgress(Long userId, Long chapterId){
        ChapterProgress chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId,userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_PROGRESS_NOT_FOUND));

        chapterProgress.updateCompletedUnits();
    }

    public List<ChapterInfoResponse> getAllChaptersWithProgress(Long userId){
        return chapterProgressRepository.findAllChaptersWithProgress(userId);
    }
}
