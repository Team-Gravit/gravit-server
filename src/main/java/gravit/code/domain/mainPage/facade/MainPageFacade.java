package gravit.code.domain.mainPage.facade;

import gravit.code.domain.mainPage.dto.response.MainPageResponse;
import gravit.code.domain.recentLearning.dto.response.RecentLearningSummaryResponse;
import gravit.code.domain.recentLearning.service.RecentLearningService;
import gravit.code.domain.mainPage.dto.response.MainPageUserSummaryResponse;
import gravit.code.domain.user.service.UserService;
import gravit.code.domain.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MainPageFacade {

    private final UserService userService;
    private final UserLeagueService userLeagueService;
    private final RecentLearningService recentLearningService;

    @Transactional(readOnly = true)
    public MainPageResponse getMainPage(Long userId){

        MainPageUserSummaryResponse mainPageUserSummary = userService.getMainPageUserSummary(userId);

        String league = userLeagueService.getUserLeagueName(userId);

        RecentLearningSummaryResponse recentLearningSummary = recentLearningService.getRecentLearningSummary(userId);

        return MainPageResponse.create(
                mainPageUserSummary.nickname(),
                mainPageUserSummary.level(),
                mainPageUserSummary.xp(),
                league,
                recentLearningSummary
        );
    }
}
