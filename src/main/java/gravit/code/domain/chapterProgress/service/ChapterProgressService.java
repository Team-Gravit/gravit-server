package gravit.code.domain.chapterProgress.service;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterProgressDetailResponse;
import gravit.code.domain.chapterProgress.dto.response.ChapterSummaryResponse;
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
        return chapterProgressRepository.findAllChapterProgressDetailByUserId(userId);
    }

    public ChapterSummaryResponse getChapterSummary(Long chapterId, Long userId) {
        return chapterProgressRepository.findChapterSummaryByChapterIdAndUserId(chapterId, userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_INFO_NOT_FOUND));
    }

    public void updateChapterProgress(Long chapterId, Long userId){

        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));

        ChapterProgress chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId,userId)
                .orElseGet(() -> ChapterProgress.create(chapter.getTotalUnits(), userId, chapterId));

        chapterProgress.updateCompletedUnits();

        chapterProgressRepository.save(chapterProgress);
    }
}
