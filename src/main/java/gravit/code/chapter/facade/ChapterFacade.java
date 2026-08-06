package gravit.code.chapter.facade;

import gravit.code.chapter.dto.internal.ChapterProgressRowDto;
import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningProgressRateService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Facade
@RequiredArgsConstructor
public class ChapterFacade {

    private static final double NOT_STARTED_PROGRESS_RATE = 0.0;

    private final ChapterQueryService chapterQueryService;
    private final LearningProgressRateService learningProgressRateService;

    @Transactional(readOnly = true)
    public List<ChapterDetailResponse> getAllChapter(long userId){
        List<ChapterSummaryResponse> chapters = chapterQueryService.getAllChapter();

        Map<Long, Double> progressRates = chapterQueryService.getAllChapterProgress(userId)
                .stream()
                .collect(Collectors.toMap(
                        ChapterProgressRowDto::chapterId,
                        row -> learningProgressRateService.calculateProgressRate(row.solvedLessons(), row.totalLessons())
                ));

        return chapters.stream()
                .map(chapter -> ChapterDetailResponse.create(
                        chapter,
                        progressRates.getOrDefault(chapter.chapterId(), NOT_STARTED_PROGRESS_RATE)
                )).toList();
    }
}
