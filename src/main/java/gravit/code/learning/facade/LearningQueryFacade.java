package gravit.code.learning.facade;

import gravit.code.chapter.dto.response.ChapterDetailResponse;
import gravit.code.chapter.dto.response.ChapterSummary;
import gravit.code.chapter.service.ChapterService;
import gravit.code.learning.service.LearningProgressRateService;
import gravit.code.lesson.dto.response.LessonDetailResponse;
import gravit.code.lesson.dto.response.LessonResponse;
import gravit.code.lesson.dto.response.LessonSummary;
import gravit.code.lesson.service.LessonService;
import gravit.code.problem.dto.response.BookmarkedProblemResponse;
import gravit.code.problem.dto.response.ProblemResponse;
import gravit.code.problem.dto.response.WrongAnsweredProblemsResponse;
import gravit.code.problem.service.ProblemService;
import gravit.code.unit.dto.response.UnitDetail;
import gravit.code.unit.dto.response.UnitDetailResponse;
import gravit.code.unit.dto.response.UnitSummary;
import gravit.code.unit.service.UnitService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Log4j2
@Service
@RequiredArgsConstructor
public class LearningQueryFacade {

    private final ChapterService chapterService;
    private final UnitService unitService;
    private final LessonService lessonService;
    private final ProblemService problemService;
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

    @Transactional(readOnly = true)
    public UnitDetailResponse getAllUnitDetailInChapter(
            long userId,
            long chapterId
    ){
        ChapterSummary chapterSummary = chapterService.getChapterSummaryByChapterId(chapterId);

        List<UnitSummary> unitSummaries = unitService.getAllUnitSummaryByChapterId(chapterId);

        List<UnitDetail> unitDetails = unitSummaries.stream()
                .map(unitSummary -> {
                    long unitId = unitSummary.unitId();

                    double unitProgressRate = learningProgressRateService.getProgressRateByUnitId(unitId, userId);

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

    @Transactional(readOnly = true)
    public LessonDetailResponse getAllLessonInUnit(
            long userId,
            long unitId
    ) {
        ChapterSummary chapterSummary = chapterService.getChapterSummaryByUnitId(unitId);

        List<LessonSummary> lessonSummaries = lessonService.getAllLessonSummaryByUnitId(unitId, userId);

        return LessonDetailResponse.create(
                chapterSummary,
                unitId,
                lessonSummaries
        );
    }

    @Transactional(readOnly = true)
    public LessonResponse getAllProblemsInLesson(
            long lessonId,
            long userId
    ){
        UnitSummary unitSummary = unitService.getUnitSummaryByLessonId(lessonId);

        List<ProblemResponse> problems = problemService.getAllProblemInLesson(lessonId, userId);

        return LessonResponse.of(
                unitSummary,
                problems
        );
    }

    @Transactional(readOnly = true)
    public BookmarkedProblemResponse getBookmarkedProblemsInUnit(
            long userId,
            long unitId
    ) {
        UnitSummary unitSummary = unitService.getUnitSummaryByUnitId(unitId);

        List<ProblemResponse> problems = problemService.getBookmarkedProblemInUnit(unitId, userId);

        return BookmarkedProblemResponse.of(
                unitSummary,
                problems
        );
    }

    @Transactional(readOnly = true)
    public WrongAnsweredProblemsResponse getWrongAnsweredProblemsInUnit(
            long userId,
            long unitId
    ) {
        UnitSummary unitSummary = unitService.getUnitSummaryByUnitId(unitId);

        List<ProblemResponse> problems = problemService.getWrongAnsweredProblemsInUnit(unitId, userId);

        return WrongAnsweredProblemsResponse.of(
                unitSummary,
                problems
        );
    }
}
