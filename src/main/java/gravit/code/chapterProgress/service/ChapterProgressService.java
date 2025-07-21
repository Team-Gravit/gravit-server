package gravit.code.chapterProgress.service;

import gravit.code.chapterProgress.domain.ChapterProgress;
import gravit.code.chapterProgress.repository.ChapterProgressRepository;
import gravit.code.common.exception.domain.CustomErrorCode;
import gravit.code.common.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ChapterProgressService {

    private final ChapterProgressRepository chapterProgressRepository;

    public void updateChapterProgress(Long userId, Long chapterId){
        ChapterProgress chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId,userId)
                        .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_PROGRESS_NOT_FOUND));

        chapterProgress.updateCompletedUnits();
    }
}
