package gravit.code.unit.facade;

import gravit.code.chapter.dto.response.ChapterSummary;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningProgressRateService;
import gravit.code.unit.dto.response.UnitDetail;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.unit.dto.response.UnitSummary;
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
    public UnitDetailResponse getAllUnitInChapter(
            long userId,
            long chapterId
    ){
        ChapterSummary chapterSummary = chapterQueryService.getChapterById(chapterId);

        List<UnitSummary> unitSummaries = unitQueryService.getAllUnitSummaryByChapterId(chapterId);

        List<UnitDetail> unitDetails = unitSummaries.stream()
                .map(unitSummary -> {
                    long unitId = unitSummary.unitId();

                    double unitProgressRate = learningProgressRateService.getUnitProgress(unitId, userId);

                    return UnitDetail.create(
                            unitSummary,
                            unitProgressRate
                    );
                }).toList();

        return UnitDetailResponse.create(
                chapterSummary,
                unitDetails
        );
    }
}
