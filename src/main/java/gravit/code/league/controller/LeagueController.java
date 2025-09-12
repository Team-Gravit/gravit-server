package gravit.code.league.controller;


import gravit.code.league.controller.docs.LeagueControllerSpecification;
import gravit.code.league.dto.response.LeagueResponse;
import gravit.code.league.service.LeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/league")
@RequiredArgsConstructor
public class LeagueController implements LeagueControllerSpecification {

    private final LeagueService leagueService;

    @GetMapping("/{leagueId}")
    public ResponseEntity<LeagueResponse> getLeague(@PathVariable("leagueId") Long leagueId) {
        return ResponseEntity.ok(leagueService.getLeague(leagueId));
    }

}
