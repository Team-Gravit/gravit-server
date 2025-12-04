package gravit.code.test.user;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.auth.token.JwtProvider;
import gravit.code.user.domain.HandleGenerator;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/test")
@RequiredArgsConstructor
public class UserCheatCreateController {

    private final AuthTokenProvider authTokenProvider;
    private final JwtProvider jwtProvider;
    private final UserRepository userRepository;
    private final UserService userService;
    private final HandleGenerator handleGenerator;

    private final String PROVIDER = "gravit";

    @PostMapping("/users/create")
    public ResponseEntity<LoginResponse> createUser(
            @RequestParam String email,
            @RequestParam String nickname,
            @RequestParam String role
    ) {
        String handle = handleGenerator.generateUniqueHandle();
        Role userRole = role.equals("admin") ? Role.ADMIN : Role.USER;
        String s = UUID.randomUUID().toString().substring(0, 6);
        User user = User.create(email,PROVIDER + s, nickname, handle, 1, userRole);
        userRepository.save(user);
        OnboardingRequest request = new OnboardingRequest(nickname, 1);
        userService.onboarding(user.getId(), request);

        AccessToken accessToken = authTokenProvider.generateAccessToken(user);
        RefreshToken refreshToken = authTokenProvider.generateRefreshToken(user);

        return ResponseEntity.ok().body(LoginResponse.of(accessToken,refreshToken,true));
    }

    @PostMapping("/users/login")
    public ResponseEntity<LoginResponse> login(
            @RequestParam Long userId
    ){
        User user = userRepository.findById(userId).get();

        AccessToken accessToken = authTokenProvider.generateAccessToken(user);
        RefreshToken refreshToken = authTokenProvider.generateRefreshToken(user);

        return ResponseEntity.ok().body(LoginResponse.of(accessToken,refreshToken,true));
    }

    @PostMapping("/tokens/custom")
    public ResponseEntity<LoginResponse> generateCustomToken(
            @RequestParam String accessToken,
            @RequestParam Long newExpirationMinutes
    ){
        User user = authTokenProvider.parseUser(accessToken);
        AccessToken newAccessToken = createNewCustomAccessToken(user, newExpirationMinutes);
        return ResponseEntity.ok().body(LoginResponse.of(newAccessToken,new RefreshToken("refresh"),true));
    }

    private AccessToken createNewCustomAccessToken(User user, Long newExpirationMinutes) {
        Subject subject = toSubject(user);
        Role role = user.getRole();

        String token = jwtProvider.generateToken(
                subject,
                Map.of("role", role.name()),
                Duration.ofMinutes(newExpirationMinutes)
        );
        return new AccessToken(token);
    }

    private Subject toSubject(User user) {
        return new Subject(user.getId().toString());
    }
}
