package gravit.code.test.user;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.auth.token.JwtProvider;
import gravit.code.friend.domain.Friend;
import gravit.code.friend.repository.FriendRepository;
import gravit.code.global.event.NoticeCreatedEvent;
import gravit.code.global.event.SeasonRolledOverEvent;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.UserService;
import gravit.code.user.support.RandomHandleGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;

@Profile("!prod")
@RestController
@RequestMapping("/api/v1/test")
@RequiredArgsConstructor
public class UserCheatCreateController {

    private final AuthTokenProvider authTokenProvider;
    private final JwtProvider jwtProvider;
    private final UserRepository userRepository;
    private final UserService userService;
    private final RandomHandleGenerator handleGenerator;
    private final FriendRepository friendRepository;
    private final ApplicationEventPublisher publisher;

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

        return ResponseEntity.ok().body(LoginResponse.of(accessToken,refreshToken,true, user.getRole()));
    }

    @PostMapping("/users/login")
    public ResponseEntity<LoginResponse> login(
            @RequestParam Long userId
    ){
        User user = userRepository.findById(userId).get();

        AccessToken accessToken = authTokenProvider.generateAccessToken(user);
        RefreshToken refreshToken = authTokenProvider.generateRefreshToken(user);

        return ResponseEntity.ok().body(LoginResponse.of(accessToken,refreshToken,true, user.getRole()));
    }

    @PostMapping("/tokens/custom")
    public ResponseEntity<LoginResponse> generateCustomToken(
            @RequestParam String accessToken,
            @RequestParam Long newExpirationMinutes
    ){
        User user = authTokenProvider.parseUser(accessToken);
        AccessToken newAccessToken = createNewCustomAccessToken(user, newExpirationMinutes);
        return ResponseEntity.ok().body(LoginResponse.of(newAccessToken,new RefreshToken("refresh"),true, user.getRole()));
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

    // 1번 유저 기준 팔로우 관계 세팅
    // - 2~10번: 1번과 맞 팔로우
    // - 11~19번: 1번을 팔로잉 (1번은 팔로잉 안 함)
    // - 20번: 관계 없음
    @Transactional
    @PostMapping("/follows/setup")
    public ResponseEntity<Void> setupFollowRelations() {
        for (long i = 2; i <= 10; i++) {
            follow(1L, i);
            follow(i, 1L);
        }
        for (long i = 11; i <= 19; i++) {
            follow(i, 1L);
        }
        return ResponseEntity.ok().build();
    }

    @PostMapping("/events/notice-created")
    public ResponseEntity<Void> publishNoticeCreatedEvent(
            @RequestParam long noticeId,
            @RequestParam String title
    ) {
        publisher.publishEvent(new NoticeCreatedEvent(noticeId, title));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/events/season-rolled-over")
    public ResponseEntity<Void> publishSeasonRolledOverEvent(
            @RequestParam String newSeasonKey
    ) {
        publisher.publishEvent(new SeasonRolledOverEvent(newSeasonKey));
        return ResponseEntity.ok().build();
    }

    private void follow(long followerId, long followeeId) {
        if (!friendRepository.existsByFollowerIdAndFolloweeId(followerId, followeeId)) {
            friendRepository.save(Friend.create(followerId, followeeId));
        }
    }
}
