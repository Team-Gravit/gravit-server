package gravit.code.domain.userLeague.controller;


import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.userLeague.controller.docs.UserLeagueRankControllerDocs;
import gravit.code.domain.userLeague.dto.response.LeagueRankRow;
import gravit.code.domain.userLeague.service.UserLeagueRankService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/rank")
@RequiredArgsConstructor
public class UserLeagueRankController implements UserLeagueRankControllerDocs {
    private final UserLeagueRankService userLeagueRankService;

    @GetMapping("/leagues/{leagueId}/page/{pageNum}")
    public ResponseEntity<List<LeagueRankRow>> getLeagueRanking(@PathVariable("leagueId") Long leagueId,
                                                                @PathVariable("pageNum") int pageNum){
        List<LeagueRankRow> leagueRanks = userLeagueRankService.getLeagueRanks(leagueId, pageNum);
        return ResponseEntity.ok(leagueRanks);
    }

    @GetMapping("/user-leagues/page/{pageNum}")
    public ResponseEntity<List<LeagueRankRow>> getLeagueRankingByUser(@PathVariable("pageNum") int pageNum,
                                                                      @AuthenticationPrincipal LoginUser loginUser){
        Long userId = loginUser.getId();
        List<LeagueRankRow> leagueRanks = userLeagueRankService.getUserLeagueRanks(userId, pageNum);
        return ResponseEntity.ok(leagueRanks);
    }
}
