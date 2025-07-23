package gravit.code.domain.mainPage.facade;

import gravit.code.domain.chapter.service.ChapterService;
import gravit.code.domain.learning.dto.response.RecentLearningInfo;
import gravit.code.domain.mainPage.dto.response.MainPageResponse;
import gravit.code.domain.user.dto.response.UserMainPageInfo;
import gravit.code.domain.user.service.UserService;
import gravit.code.domain.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MainPageFacade {

    private final ChapterService chapterService;
    private final UserService userService;
    private final UserLeagueService userLeagueService;

    @Transactional(readOnly = true)
    public MainPageResponse getMainPage(Long userId){

        UserMainPageInfo userMainPageInfo = userService.getUserMainPageInfo(userId);

        String league = userLeagueService.getUserLeagueName(userId);

        Optional<RecentLearningInfo> recentLearningChapter = chapterService.getRecentLearningChapter(userId);

        if(recentLearningChapter.isPresent()) {
            return MainPageResponse.create(
                    userMainPageInfo.nickname(),
                    userMainPageInfo.level(),
                    userMainPageInfo.xp(),
                    league,
                    recentLearningChapter.get()
            );
        }else{
            return MainPageResponse.create(
                    userMainPageInfo.nickname(),
                    userMainPageInfo.level(),
                    userMainPageInfo.xp(),
                    league,
                    new RecentLearningInfo(-1L, "-", "-", -1L, -1L)
            );
        }
    }
}
