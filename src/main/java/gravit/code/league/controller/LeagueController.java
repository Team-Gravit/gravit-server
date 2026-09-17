package gravit.code.league.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.league.controller.docs.LeagueControllerDocs;
import gravit.code.league.dto.response.LeagueHomeResponse;
import gravit.code.league.dto.response.LeagueResponse;
import gravit.code.league.service.LeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequestMapping("/api/v1/league")
@RequiredArgsConstructor
public class LeagueController implements LeagueControllerDocs {

    private final LeagueService leagueService;

    @GetMapping("/{leagueId}")
    public ResponseEntity<LeagueResponse> getLeague(@PathVariable("leagueId") Long leagueId) {
        return ResponseEntity.status(OK).body(leagueService.getLeague(leagueId));
    }

    @GetMapping("/home")
    public ResponseEntity<LeagueHomeResponse> enterHome(@AuthenticationPrincipal LoginUser loginUser) {
        Long userId = loginUser.getId();
        LeagueHomeResponse leagueHome = leagueService.enterLeagueHome(userId);

        return ResponseEntity.status(OK).body(leagueHome);
    }

}
