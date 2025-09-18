package gravit.code.userLeague.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.userLeague.controller.docs.MyLeagueProfileQueryControllerDocs;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.service.MyLeagueProfileQueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/v1/ranking/me")
@RequiredArgsConstructor
public class MyLeagueProfileQueryController implements MyLeagueProfileQueryControllerDocs {
    private final MyLeagueProfileQueryService myLeagueInfoQueryService;

    @GetMapping
    public ResponseEntity<MyLeagueRankWithProfileResponse> getMyLeagueWithProfile(@AuthenticationPrincipal LoginUser loginUser) {
        Long userId = loginUser.getId();
        MyLeagueRankWithProfileResponse myLeagueRankWithProfile = myLeagueInfoQueryService.getMyLeagueRankWithProfile(userId);

        return ResponseEntity.ok(myLeagueRankWithProfile);
    }
}
