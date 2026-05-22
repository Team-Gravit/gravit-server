package gravit.code.userLeagueHistory.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.league.dto.response.LeagueHistoryResponse;
import gravit.code.userLeagueHistory.controller.docs.LeagueHistoryControllerDocs;
import gravit.code.userLeagueHistory.service.LeagueHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/league-history")
@RequiredArgsConstructor
public class LeagueHistoryController implements LeagueHistoryControllerDocs {

    private final LeagueHistoryService leagueHistoryService;

    @GetMapping("/me")
    public ResponseEntity<LeagueHistoryResponse> getMyLeagueHistory(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.ok(leagueHistoryService.getMyLeagueHistory(loginUser.getId()));
    }
}
