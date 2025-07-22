package gravit.code.user.presentation;

import gravit.code.common.auth.oauth.LoginUser;
import gravit.code.user.application.UserService;
import gravit.code.user.application.dto.request.OnboardingRequest;
import gravit.code.user.application.dto.response.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    @GetMapping()
    public ResponseEntity<UserResponse> getUser(@AuthenticationPrincipal LoginUser loginUser) {
        UserResponse userResponse = userService.findById(loginUser.getId());
        return ResponseEntity.ok(userResponse);
    }

    @PatchMapping("/onboarding")
    public ResponseEntity<UserResponse> onboardUser(@AuthenticationPrincipal LoginUser loginUser,
                                              @RequestBody OnboardingRequest request) {
        UserResponse userResponse = userService.onboarding(loginUser.getId(), request);
        return ResponseEntity.ok(userResponse);
    }
}
