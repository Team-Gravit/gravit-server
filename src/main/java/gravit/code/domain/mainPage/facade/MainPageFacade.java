package gravit.code.domain.mainPage.facade;

import gravit.code.domain.mainPage.dto.response.MainPageResponse;
import gravit.code.domain.recentLearning.dto.response.RecentLearningInfo;
import gravit.code.domain.recentLearning.service.RecentLearningService;
import gravit.code.domain.user.dto.response.UserMainPageInfo;
import gravit.code.domain.user.service.UserService;
import gravit.code.domain.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MainPageFacade {

    private final RecentLearningService recentLearningService;
    private final UserService userService;
    private final UserLeagueService userLeagueService;

    @Transactional(readOnly = true)
    public MainPageResponse getMainPage(Long userId){

        UserMainPageInfo userMainPageInfo = userService.getUserMainPageInfo(userId);

        String league = userLeagueService.getUserLeagueName(userId);

        RecentLearningInfo recentLearningInfo = recentLearningService.getRecentLearningInfo(userId);


        return MainPageResponse.create(
                userMainPageInfo.nickname(),
                userMainPageInfo.level(),
                userMainPageInfo.xp(),
                league,
                recentLearningInfo
        );
    }
}
