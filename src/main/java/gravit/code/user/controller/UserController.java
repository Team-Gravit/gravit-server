package gravit.code.user.controller;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.user.controller.docs.UserControllerDocs;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserResponse;
import gravit.code.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController implements UserControllerDocs {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<UserResponse> getUser(@AuthenticationPrincipal LoginUser loginUser) {
        UserResponse userResponse = userService.findById(loginUser.getId());
        return ResponseEntity.ok(userResponse);
    }

    @PostMapping("/me/onboarding")
    public ResponseEntity<UserResponse> onboardUser(@AuthenticationPrincipal LoginUser loginUser,
                                                    @Valid @RequestBody OnboardingRequest request) {
        UserResponse userResponse = userService.onboarding(loginUser.getId(), request);
        return ResponseEntity.ok(userResponse);
    }

    @PatchMapping("/me")
    public ResponseEntity<UserResponse> updateProfile(@AuthenticationPrincipal LoginUser loginUser,
                                                      @Valid @RequestBody UserProfileUpdateRequest request) {
        UserResponse userResponse = userService.updateUserProfile(loginUser.getId(), request);
        return ResponseEntity.ok(userResponse);
    }

    @GetMapping("/me/my-page")
    public ResponseEntity<MyPageResponse> getMyPage(@AuthenticationPrincipal LoginUser loginUser) {
        MyPageResponse myPageResponse = userService.getMyPage(loginUser.getId());
        return ResponseEntity.ok(myPageResponse);
    }

    @DeleteMapping("/me/delete")
    public ResponseEntity<Void> deleteUser(@AuthenticationPrincipal LoginUser loginUser){
        Long userId = loginUser.getId();
        userService.deleteUser(userId);
        return ResponseEntity.ok().build();
    }

}
