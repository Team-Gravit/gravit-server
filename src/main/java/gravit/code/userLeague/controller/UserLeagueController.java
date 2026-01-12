package gravit.code.userLeague.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.userLeague.controller.docs.UserLeagueControllerDocs;
import gravit.code.userLeague.dto.response.LeagueRankRow;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.service.UserLeagueQueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/v1/ranking")
@RequiredArgsConstructor
public class UserLeagueController implements UserLeagueControllerDocs {

    private final UserLeagueQueryService userLeagueQueryService;

    @GetMapping("/me")
    public ResponseEntity<MyLeagueRankWithProfileResponse> getMyLeagueWithProfile(@AuthenticationPrincipal LoginUser loginUser) {
        Long userId = loginUser.getId();
        MyLeagueRankWithProfileResponse myLeagueRankWithProfile = userLeagueQueryService.getMyLeagueRankWithProfile(userId);

        return ResponseEntity.ok(myLeagueRankWithProfile);
    }

    @GetMapping("/leagues/{leagueId}/page/{pageNum}")
    public ResponseEntity<SliceResponse<LeagueRankRow>> getLeagueRanking(
            @PathVariable("leagueId") Long leagueId,
            @PathVariable("pageNum") int pageNum
    ){
        SliceResponse<LeagueRankRow> sliceResponse = userLeagueQueryService.findLeagueRanking(leagueId, pageNum);
        return ResponseEntity.ok(sliceResponse);
    }

    @GetMapping("/user-leagues/page/{pageNum}")
    public ResponseEntity<SliceResponse<LeagueRankRow>> getLeagueRankingByUser(
            @PathVariable("pageNum") int pageNum,
            @AuthenticationPrincipal LoginUser loginUser
    ){
        Long userId = loginUser.getId();
        SliceResponse<LeagueRankRow> sliceResponse = userLeagueQueryService.findLeagueRankingByUser(userId, pageNum);
        return ResponseEntity.ok(sliceResponse);
    }
}
