package gravit.code.user.controller;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.user.service.UserDeleteWithMailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users/me/delete")
public class UserDeleteWithMailController {

    private final UserDeleteWithMailService userDeleteWithMailService;

    @PostMapping("/request")
    public ResponseEntity<Void> request(@AuthenticationPrincipal LoginUser loginUser){
        Long userId = loginUser.getId();
        userDeleteWithMailService.requestDeleteMailWithMailAuthCode(userId);
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/confirm")
    public ResponseEntity<Void> confirm(@RequestParam String mailAuthCode){
        userDeleteWithMailService.confirmDeleteByMailAuthCode(mailAuthCode);
        return ResponseEntity.ok().build();
    }
}
