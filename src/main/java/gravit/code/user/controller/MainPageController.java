package gravit.code.user.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.dailyLearningRecord.facade.DailyLearningRecordFacade;
import gravit.code.league.dto.response.LeagueDetailResponse;
import gravit.code.learning.dto.response.LearningDetailResponse;
import gravit.code.learning.facade.LearningFacade;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.mission.service.MissionService;
import gravit.code.unit.dto.response.RecommendedUnitResponse;
import gravit.code.unit.service.UnitQueryService;
import gravit.code.user.controller.docs.MainPageControllerDocs;
import gravit.code.user.dto.response.ProfileSummaryResponse;
import gravit.code.user.facade.UserFacade;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/main-pages")
public class MainPageController implements MainPageControllerDocs {

    private final UserFacade userFacade;
    private final LearningFacade learningFacade;
    private final UserLeagueService userLeagueService;
    private final UnitQueryService unitQueryService;
    private final DailyLearningRecordFacade dailyLearningRecordFacade;
    private final MissionService missionService;

    @GetMapping("/profile")
    public ResponseEntity<ProfileSummaryResponse> getProfile(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(userFacade.getProfileSummary(loginUser.getId()));
    }

    @GetMapping("/league")
    public ResponseEntity<LeagueDetailResponse> getLeague(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(userLeagueService.getUserLeagueDetail(loginUser.getId()));
    }

    @GetMapping("/learning")
    public ResponseEntity<LearningDetailResponse> getLearning(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(learningFacade.getLearningDetail(loginUser.getId()));
    }

    @GetMapping("/units")
    public ResponseEntity<List<RecommendedUnitResponse>> getUnits(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(unitQueryService.getRecommendedUnits(loginUser.getId()));
    }

    @GetMapping("/weekly-record")
    public ResponseEntity<WeeklyLearningRecordResponse> getWeeklyRecord(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(dailyLearningRecordFacade.getWeeklyLearningRecord(loginUser.getId()));
    }

    @GetMapping("/mission")
    public ResponseEntity<MissionDetailResponse> getMission(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(missionService.getMissionDetail(loginUser.getId()));
    }
}
