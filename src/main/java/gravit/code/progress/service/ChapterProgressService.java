package gravit.code.progress.service;

import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.ChapterRepository;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.domain.ChapterProgressRepository;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.dto.response.ChapterSummaryResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChapterProgressService {

    private final ChapterRepository chapterRepository;
    private final ChapterProgressRepository chapterProgressRepository;

    public List<ChapterProgressDetailResponse> getChapterProgressDetails(Long userId){
        List<ChapterProgressDetailResponse> chapterProgressDetailResponses = chapterProgressRepository.findAllChapterProgressDetailByUserId(userId);

        if(chapterProgressDetailResponses.isEmpty())
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);

        return chapterProgressDetailResponses;
    }

    public ChapterSummaryResponse getChapterSummary(Long chapterId, Long userId) {
        return chapterProgressRepository.findChapterSummaryByChapterIdAndUserId(chapterId, userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_SUMMARY_NOT_FOUND));
    }

    public void updateChapterProgress(ChapterProgress chapterProgress){
        chapterProgress.updateCompletedUnits();
    }

    public ChapterProgress ensureChapterProgress(Long chapterId, Long userId){
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));

        ChapterProgress chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId,userId)
                .orElseGet(() -> ChapterProgress.create(chapter.getTotalUnits(), userId, chapterId));

        return chapterProgressRepository.save(chapterProgress);
    }
}
