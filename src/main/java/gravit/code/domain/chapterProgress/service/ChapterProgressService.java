package gravit.code.domain.chapterProgress.service;

import gravit.code.domain.chapter.domain.Chapter;
import gravit.code.domain.chapter.domain.ChapterRepository;
import gravit.code.domain.chapterProgress.domain.ChapterProgress;
import gravit.code.domain.chapterProgress.domain.ChapterProgressRepository;
import gravit.code.domain.chapterProgress.dto.response.ChapterInfo;
import gravit.code.domain.chapterProgress.dto.response.ChapterInfoResponse;
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

    public void updateChapterProgress(Long userId, Long chapterId){

        Chapter targetChapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));

        ChapterProgress chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId,userId)
                .orElseGet(() -> ChapterProgress.create(targetChapter.getTotalUnits(), userId, chapterId));

        chapterProgress.updateCompletedUnits();

        chapterProgressRepository.save(chapterProgress);
    }

    public List<ChapterInfoResponse> getAllChaptersWithProgress(Long userId){
        return chapterProgressRepository.findAllChaptersWithProgress(userId);
    }

    public ChapterInfo getChapterInfo(Long userId, Long chapterId) {
        return chapterProgressRepository.findChapterInfoByChapterIdAndUserId(userId, chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_INFO_NOT_FOUND));
    }
}
