package gravit.code.user.facade;

import gravit.code.chapter.domain.Chapter;
import gravit.code.chapter.service.ChapterQueryService;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.annotation.Facade;
import gravit.code.league.dto.response.LeagueDetailResponse;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.learning.service.LearningCommandService;
import gravit.code.learning.service.LearningProgressRateService;
import gravit.code.learning.service.LearningQueryService;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.mission.service.MissionService;
import gravit.code.unit.dto.response.RecommendedUnitResponse;
import gravit.code.unit.dto.response.UnitProgressSummaryResponse;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.user.domain.User;
import gravit.code.user.dto.response.MainPageResponse;
import gravit.code.user.dto.response.MyPageBannerResponse;
import gravit.code.user.dto.response.UserLevelDetailResponse;
import gravit.code.user.service.UserService;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Facade
@RequiredArgsConstructor
public class UserFacade {

    private final UserService userService;
    private final UserLeagueService userLeagueService;
    private final UnitQueryService unitQueryService;
    private final LearningQueryService learningQueryService;
    private final LearningCommandService learningCommandService;
    private final ChapterQueryService chapterQueryService;
    private final LearningProgressRateService learningProgressRateService;
    private final MissionService missionService;
    private final DailyLearningRecordService dailyLearningRecordService;

    @Transactional(readOnly = true)
    public MainPageResponse getMainPage(long userId) {
        User user = userService.getUser(userId);
        Learning learning = learningQueryService.getLearning(userId);

        UserLevelDetailResponse userLevelDetailResponse = user.getLevel().getUserLevelDetail();
        LeagueDetailResponse leagueDetailResponse = userLeagueService.getUserLeagueDetail(userId);
        LearningDetailResponse learningDetailResponse = getLearningDetail(userId, learning);
        List<RecommendedUnitResponse> recommendedUnitResponses = unitQueryService.getRecommendedUnits(userId);
        WeeklyLearningRecordResponse weeklyLearningRecordResponse = dailyLearningRecordService.getWeeklyLearningRecord(userId);
        MissionDetailResponse missionDetailResponse = missionService.getMissionDetail(userId);

        return MainPageResponse.of(
                user.getProfileImgNumber(),
                user.getNickname(),
                userLevelDetailResponse,
                leagueDetailResponse,
                learningDetailResponse,
                recommendedUnitResponses,
                weeklyLearningRecordResponse,
                missionDetailResponse
        );
    }

    @Transactional(readOnly = true)
    public MyPageBannerResponse getMyPageBanner(long userId){
        User user = userService.getUser(userId);
        String leagueName = userLeagueService.getUserLeagueName(userId);
        Learning learning = learningQueryService.getLearning(userId);

        return MyPageBannerResponse.of(
                user.getProfileImgNumber(),
                user.getNickname(),
                user.getHandle(),
                user.getLevel().getLevel(),
                leagueName,
                learning.getConsecutiveSolvedDays()
        );
    }

    private LearningDetailResponse getLearningDetail(
            long userId,
            Learning learning
    ) {
        long chapterId = learning.getRecentSolvedChapterId();

        List<UnitProgressSummaryResponse> units = unitQueryService.getAllUnitProgressSummariesInChapter(chapterId, userId);

        Chapter recentSolvedChapter = chapterQueryService.getChapter(chapterId);

        double chapterProgressRate = learningProgressRateService.getChapterProgress(chapterId, userId);

        return LearningDetailResponse.of(
                learning.getConsecutiveSolvedDays(),
                recentSolvedChapter.getId(),
                recentSolvedChapter.getTitle(),
                chapterProgressRate,
                units
        );
    }
}
