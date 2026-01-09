package gravit.code.chapter.facade;

import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.dto.response.ChapterSummary;
import gravit.code.chapter.service.ChapterService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningProgressRateService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class ChapterFacade {

    private final ChapterService chapterService;

    private final LearningProgressRateService learningProgressRateService;

    @Transactional(readOnly = true)
    public List<ChapterDetailResponse> getAllChapterDetail(long userId){
        List<ChapterSummary> chapterSummaries = chapterService.getAllChapterSummary();

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
