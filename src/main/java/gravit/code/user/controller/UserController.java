package gravit.code.user.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.user.controller.docs.UserControllerDocs;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MainPageResponse;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserResponse;
import gravit.code.user.service.UserDeletionService;
import gravit.code.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/users")
public class UserController implements UserControllerDocs {

    private final UserService userService;
    private final UserDeletionService deletionService;
    private final UserDeletionService userDeletionService;

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

    @GetMapping("/main-page")
    public ResponseEntity<MainPageResponse> getMainPage(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(HttpStatus.OK).body(userService.getMainPage(loginUser.getId()));
    }

    @PostMapping("/deletion/request")
    public ResponseEntity<Void> deletionRequest(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam String dest
    ) {
        Long userId = loginUser.getId();
        userDeletionService.requestDeletion(userId, dest);
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/deletion/confirm")
    public ResponseEntity<Void> deletionConfirm(@RequestParam String mailAuthCode) {
        deletionService.confirmAndDelete(mailAuthCode);
        return ResponseEntity.ok().build();
    }
}
