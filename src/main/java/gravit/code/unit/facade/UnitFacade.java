package gravit.code.unit.facade;

import gravit.code.chapter.dto.response.ChapterSummaryResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningProgressRateService;
import gravit.code.unit.dto.internal.UnitProgressRowDto;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.unit.dto.response.UnitPageResponse;
import gravit.code.unit.dto.response.UnitSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Facade
@RequiredArgsConstructor
public class UnitFacade {

    private static final double NOT_STARTED_PROGRESS_RATE = 0.0;

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

        Map<Long, Double> progressRates = unitQueryService.getAllUnitProgressInChapter(chapterId, userId)
                .stream()
                .collect(Collectors.toMap(
                        UnitProgressRowDto::unitId,
                        row -> learningProgressRateService.calculateProgressRate(row.solvedLessons(), row.totalLessons())
                ));

        List<UnitDetailResponse> unitDetailResponses = unitSummaries.stream()
                .map(unitSummary -> UnitDetailResponse.create(
                        unitSummary,
                        progressRates.getOrDefault(unitSummary.unitId(), NOT_STARTED_PROGRESS_RATE)
                )).toList();

        return UnitPageResponse.create(
                chapterSummaryResponse,
                unitDetailResponses
        );
    }
}
