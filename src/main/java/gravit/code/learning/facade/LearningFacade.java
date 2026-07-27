package gravit.code.learning.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse;
import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.annotation.Facade;
import gravit.code.global.consts.TimeZoneConst;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.learning.dto.response.LearningHistoryResponse;
import gravit.code.learning.dto.response.LearningSummaryResponse;
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
    public LearningSummaryResponse getMyPageSummary(long userId) {
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

    @Transactional(readOnly = true)
    public LearningHistoryResponse getMyPageLearningHistory(
            long userId,
            int year
    ) {
        List<DailySolvedCountResponse> dailySolvedCountResponses = dailyLearningRecordService.getDailySolvedCounts(userId, year);
        int peakLearningHour = lessonSubmissionQueryService.getPeakLearningHour(userId);

        int currentYear = LocalDate.now(TimeZoneConst.KST).getYear();
        int signUpYear = userService.getUser(userId).getCreatedAt().getYear();
        List<Integer> availableYears = IntStream.rangeClosed(signUpYear, currentYear)
                .boxed()
                .toList();

        return LearningHistoryResponse.of(
                dailySolvedCountResponses,
                peakLearningHour,
                availableYears
        );
    }
}
