package gravit.code.chapter.facade;

import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.dto.response.ChapterSummary;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningProgressRateService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class ChapterFacade {

    private final ChapterQueryService chapterQueryService;
    private final LearningProgressRateService learningProgressRateService;

    @Transactional(readOnly = true)
    public List<ChapterDetailResponse> getAllChapter(long userId){
        List<ChapterSummary> chapterSummaries = chapterQueryService.getAllChapterSummary();

        return chapterSummaries.stream()
                .map(chapterSummary -> {
                    long chapterId = chapterSummary.chapterId();

                    double chapterProgressRate = learningProgressRateService.getProgressRateByChapterId(chapterId, userId);

                    return ChapterDetailResponse.create(
                            chapterSummary,
                            chapterProgressRate
                    );
                }).toList();
    }
}
