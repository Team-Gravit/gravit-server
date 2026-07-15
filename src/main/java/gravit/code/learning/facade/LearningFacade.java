package gravit.code.learning.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.dto.response.TopChapterResponse;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningReportResponse;
import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.consts.TimeZoneConst;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.learning.dto.response.LearningHistoryResponse;
import gravit.code.learning.dto.response.LearningSummaryResponse;
import gravit.code.learning.dto.response.MyPageLearningResponse;
import gravit.code.learning.dto.response.MyPageSummaryResponse;
import gravit.code.learning.dto.response.WeakConceptResponse;
import gravit.code.learning.service.LearningProgressRateService;
import gravit.code.learning.service.LearningQueryService;
import gravit.code.lesson.service.LessonQueryService;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.unit.dto.response.UnitProgressSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.IntStream;

@Facade
@RequiredArgsConstructor
public class LearningFacade {

    private final LearningProgressRateService learningProgressRateService;
    private final LearningQueryService learningQueryService;
    private final LessonSubmissionQueryService lessonSubmissionQueryService;
    private final LessonQueryService lessonQueryService;
    private final DailyLearningRecordService dailyLearningRecordService;
    private final UnitQueryService unitQueryService;
    private final ChapterQueryService chapterQueryService;
    private final UserService userService;

    @Transactional(readOnly = true)
    public LearningDetailResponse getLearningDetail(long userId) {
        Learning learning = learningQueryService.getLearning(userId);
        long chapterId = learning.getRecentSolvedChapterId();

        List<UnitProgressSummaryResponse> units = unitQueryService.getAllUnitProgressSummariesInChapter(chapterId, userId);

        Chapter recentSolvedChapter = chapterQueryService.getChapter(chapterId);
        double chapterProgressRate = learningProgressRateService.getChapterProgress(chapterId, userId);

        return LearningDetailResponse.of(
                recentSolvedChapter.getId(),
                recentSolvedChapter.getTitle(),
                chapterProgressRate,
                units
        );
    }

    @Transactional(readOnly = true)
    public MyPageLearningResponse getMyPageLearning(long userId) {
        WeeklyLearningReportResponse weeklyReport = getWeeklyLearningReport(userId);
        List<TopChapterResponse> topChapters = getTopChapters(userId);
        List<WeakConceptResponse> weakConcepts = getWeakConcepts(userId);

        return MyPageLearningResponse.of(
                weeklyReport,
                topChapters,
                weakConcepts
        );
    }

    @Transactional(readOnly = true)
    public MyPageSummaryResponse getMyPageSummary(long userId) {
        int currentYear = LocalDate.now(TimeZoneConst.KST).getYear();
        int signUpYear = userService.getUser(userId).getCreatedAt().getYear();

        LearningSummaryResponse learningSummary = getLearningSummary(userId);
        LearningHistoryResponse learningHistory = getLearningHistory(userId, currentYear);

        List<Integer> availableYears = IntStream.rangeClosed(signUpYear, currentYear)
                .boxed()
                .toList();

        return MyPageSummaryResponse.of(
                learningSummary,
                learningHistory,
                availableYears
        );
    }

    @Transactional(readOnly = true)
    public LearningHistoryResponse getMyPageLearningHistory(
            long userId,
            int year
    ) {
        return getLearningHistory(userId, year);
    }

    private LearningSummaryResponse getLearningSummary(long userId) {
        int rankPercentile = learningProgressRateService.getLearningRankPercentile(userId);
        int completedLessonCount = lessonSubmissionQueryService.getCompletedLessonCount(userId);
        int totalLessonCount = lessonQueryService.getTotalLessonCount();
        double totalLearningHours = lessonSubmissionQueryService.getTotalLearningHours(userId);
        int averageAccuracy = lessonSubmissionQueryService.getAverageAccuracy(userId);

        return LearningSummaryResponse.of(
                rankPercentile,
                completedLessonCount,
                totalLessonCount,
                totalLearningHours,
                averageAccuracy
        );
    }

    private LearningHistoryResponse getLearningHistory(
            long userId,
            int year
    ) {
        List<DailySolvedCountResponse> dailySolvedCountResponses = dailyLearningRecordService.getDailySolvedCounts(userId, year);
        int peakLearningHour = lessonSubmissionQueryService.getPeakLearningHour(userId);

        return LearningHistoryResponse.of(
                dailySolvedCountResponses,
                peakLearningHour
        );
    }

    private WeeklyLearningReportResponse getWeeklyLearningReport(long userId) {
        return dailyLearningRecordService.getWeeklyLearningReport(userId);
    }

    private List<TopChapterResponse> getTopChapters(long userId) {
        return lessonSubmissionQueryService.getTopChapters(userId);
    }

    private List<WeakConceptResponse> getWeakConcepts(long userId) {
        return lessonSubmissionQueryService.getWeakConcepts(userId);
    }
}
