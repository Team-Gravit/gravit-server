package gravit.code.user.controller;

import gravit.code.auth.domain.LoginUser;
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

    @PostMapping("/onboarding")
    public ResponseEntity<UserResponse> onboardUser(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody OnboardingRequest request
    ) {
        UserResponse userResponse = userService.onboarding(loginUser.getId(), request);
        return ResponseEntity.ok(userResponse);
    }

    @PatchMapping
    public ResponseEntity<UserResponse> updateProfile(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody UserProfileUpdateRequest request
    ) {
        UserResponse userResponse = userService.updateUserProfile(loginUser.getId(), request);
        return ResponseEntity.ok(userResponse);
    }

    @GetMapping("/my-page")
    public ResponseEntity<MyPageResponse> getMyPage(@AuthenticationPrincipal LoginUser loginUser) {
        MyPageResponse myPageResponse = userService.getMyPage(loginUser.getId());
        return ResponseEntity.ok(myPageResponse);
    }

    @PatchMapping("/restore")
    public ResponseEntity<Void> restoreUser(@RequestParam("providerId") String providerId) {
        userService.restoreUser(providerId);
        return ResponseEntity.ok().build();
    }
}