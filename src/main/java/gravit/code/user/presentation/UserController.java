package gravit.code.user.presentation;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.user.application.UserService;
import gravit.code.user.application.dto.request.OnboardingRequest;
import gravit.code.user.application.dto.response.UserResponse;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserRepository userRepository;
    private final UserService userService;

    @GetMapping()
    public ResponseEntity<String> getUser(@AuthenticationPrincipal LoginUser loginUser) {
        User user = userRepository.findById(loginUser.getId()).orElseThrow(RuntimeException::new);
        return ResponseEntity.ok("유저 조회 성공 : " + user.getNickname());
    }

    @PatchMapping("/onboarding")
    public ResponseEntity<UserResponse> onboardUser(@AuthenticationPrincipal LoginUser loginUser,
                                              @RequestBody OnboardingRequest request) {
        UserResponse userResponse = userService.onboarding(loginUser.getId(), request);
        return ResponseEntity.ok(userResponse);
    }
}
