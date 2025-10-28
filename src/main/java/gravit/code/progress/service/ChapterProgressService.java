package gravit.code.progress.service;

import gravit.code.global.event.badge.PlanetCompletedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Chapter;
import gravit.code.learning.domain.ChapterRepository;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.progress.domain.ChapterProgressRepository;
import gravit.code.progress.dto.ChapterCompletedDto;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChapterProgressService {

    private final ChapterRepository chapterRepository;
    private final ChapterProgressRepository chapterProgressRepository;

    private final ApplicationEventPublisher publisher;

    @Transactional(readOnly = true)
    public List<ChapterProgressDetailResponse> getChapterProgressDetails(long userId){
        List<ChapterProgressDetailResponse> chapterProgressDetailResponses = chapterProgressRepository.findAllChapterProgressDetailByUserId(userId);

        if(chapterProgressDetailResponses.isEmpty())
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);

        return chapterProgressDetailResponses;
    }

    @Transactional
    public void updateChapterProgress(ChapterProgress chapterProgress){
        ChapterCompletedDto dto = chapterProgress.updateCompletedUnits();
        publisher.publishEvent(new PlanetCompletedEvent(
                chapterProgress.getUserId(), chapterProgress.getChapterId(), dto.before(), dto.after(), dto.totalUnits())
        );
    }

    @Transactional
    public ChapterProgress ensureChapterProgress(
            long chapterId,
            long userId
    ){
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.CHAPTER_NOT_FOUND));

        ChapterProgress chapterProgress = chapterProgressRepository.findByChapterIdAndUserId(chapterId,userId)
                .orElseGet(() -> ChapterProgress.create(chapter.getTotalUnits(), userId, chapterId));

        return chapterProgressRepository.save(chapterProgress);
    }
}
