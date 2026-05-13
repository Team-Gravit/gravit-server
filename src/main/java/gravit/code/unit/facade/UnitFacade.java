package gravit.code.unit.facade;

import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningProgressRateService;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.unit.dto.response.UnitPageResponse;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class UnitFacade {

    private final UnitQueryService unitQueryService;

    private final ChapterQueryService chapterQueryService;
    private final LearningProgressRateService learningProgressRateService;

    @Transactional(readOnly = true)
    public UnitPageResponse getAllUnitInChapter(
            long userId,
            long chapterId
    ){
        ChapterSummaryResponse chapterSummaryResponse = chapterQueryService.getChapterSummary(chapterId);

        List<UnitSummaryResponse> unitSummaries = unitQueryService.getAllUnitSummaryByChapterId(chapterId);

        List<UnitDetailResponse> unitDetailResponses = unitSummaries.stream()
                .map(unitSummary -> {
                    long unitId = unitSummary.unitId();

                    double unitProgressRate = learningProgressRateService.getUnitProgress(unitId, userId);

                    return UnitDetailResponse.create(
                            unitSummary,
                            unitProgressRate
                    );
                }).toList();

        return UnitPageResponse.create(
                chapterSummaryResponse,
                unitDetailResponses
        );
    }
}
