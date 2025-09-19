package gravit.code.badge.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.badge.dto.response.AllBadgesResponse;
import gravit.code.badge.service.BadgeQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/badges")
public class BadgeQueryController {

    private final BadgeQueryService badgeQueryService;

    @GetMapping("/me")
    public ResponseEntity<AllBadgesResponse> getAllMyBadges(@AuthenticationPrincipal LoginUser loginUser){
        Long userId = loginUser.getId();
        AllBadgesResponse allBadges = badgeQueryService.getAllMyBadges(userId);
        HttpStatus status = HttpStatus.OK;
        return ResponseEntity.status(status).body(allBadges);
    }

}
