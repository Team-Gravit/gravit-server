package gravit.code.user.presentation;

import gravit.code.common.auth.oauth.LoginUser;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserRepository userRepository;

    @GetMapping()
    public ResponseEntity<String> getUser(@AuthenticationPrincipal LoginUser loginUser) {
        User user = userRepository.findById(loginUser.getId()).orElseThrow(RuntimeException::new);
        return ResponseEntity.ok("유저 조회 성공 : " + user.getNickname());
    }
}
