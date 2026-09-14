package gravit.code.test.user;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.auth.token.JwtProvider;
import gravit.code.friend.domain.Friend;
import gravit.code.friend.repository.FriendRepository;
import gravit.code.notice.dto.event.NoticeCreatedEvent;
import gravit.code.test.user.docs.TestUserCheatCreateControllerDocs;
import gravit.code.global.exception.domain.RestApiException;
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
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.Map;
import java.util.UUID;

import static gravit.code.global.exception.domain.CustomErrorCode.NICKNAME_LENGTH_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.NICKNAME_NOT_NULL;
import static gravit.code.global.exception.domain.CustomErrorCode.NICKNAME_PATTERN_INVALID;
import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.OK;

@Profile("!prod")
@RestController
@RequestMapping("/api/v1/test")
@RequiredArgsConstructor
public class TestUserCheatCreateController implements TestUserCheatCreateControllerDocs {

    private static final String PROVIDER = "gravit";
    private static final int NICKNAME_MIN_LENGTH = 2;
    private static final int NICKNAME_MAX_LENGTH = 8;
    private static final String NICKNAME_PATTERN = "^[가-힣a-zA-Z0-9]+$";
    private static final long MAIN_USER_ID = 1L;
    private static final long MUTUAL_FOLLOWER_FIRST_ID = 2L;
    private static final long MUTUAL_FOLLOWER_LAST_ID = 10L;
    private static final long ONE_WAY_FOLLOWER_FIRST_ID = 11L;
    private static final long ONE_WAY_FOLLOWER_LAST_ID = 19L;

    private final UserService userService;

    private final UserRepository userRepository;
    private final FriendRepository friendRepository;

    private final AuthTokenProvider authTokenProvider;
    private final JwtProvider jwtProvider;
    private final RandomHandleGenerator handleGenerator;

    private final ApplicationEventPublisher publisher;

    @Transactional
    @PostMapping("/users/create")
    public ResponseEntity<LoginResponse> createUser(
            @RequestParam String email,
            @RequestParam String nickname,
            @RequestParam String role
    ) {
        validateEmail(email);
        Role userRole = parseRole(role);
        validateNickname(nickname);

        String handle = handleGenerator.generateUniqueHandle();
        String s = UUID.randomUUID().toString().substring(0, 6);
        User user = User.create(email,PROVIDER + s, nickname, handle, 1, userRole);
        userRepository.save(user);
        OnboardingRequest request = new OnboardingRequest(nickname, 1);
        userService.onboard(user.getId(), request);

        AccessToken accessToken = authTokenProvider.generateAccessToken(user);
        RefreshToken refreshToken = authTokenProvider.generateRefreshToken(user);

        return ResponseEntity.status(OK).body(LoginResponse.of(accessToken,refreshToken,true, user.getRole()));
    }

    private void validateEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new ResponseStatusException(BAD_REQUEST, "이메일이 null 이거나 empty 일 순 없습니다.");
        }
    }

    private Role parseRole(String role) {
        if (role == null || role.isBlank()) {
            throw new ResponseStatusException(BAD_REQUEST, "유효하지 않은 권한 값입니다.");
        }
        try {
            return Role.valueOf(role.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(BAD_REQUEST, "유효하지 않은 권한 값입니다.");
        }
    }

    private void validateNickname(String nickname) {
        if (nickname == null || nickname.isBlank()) {
            throw new RestApiException(NICKNAME_NOT_NULL);
        }
        if (nickname.length() < NICKNAME_MIN_LENGTH || nickname.length() > NICKNAME_MAX_LENGTH) {
            throw new RestApiException(NICKNAME_LENGTH_INVALID);
        }
        if (!nickname.matches(NICKNAME_PATTERN)) {
            throw new RestApiException(NICKNAME_PATTERN_INVALID);
        }
    }

    @PostMapping("/users/login")
    public ResponseEntity<LoginResponse> login(
            @RequestParam Long userId
    ){
        User user = userRepository.findById(userId).get();

        AccessToken accessToken = authTokenProvider.generateAccessToken(user);
        RefreshToken refreshToken = authTokenProvider.generateRefreshToken(user);

        return ResponseEntity.status(OK).body(LoginResponse.of(accessToken,refreshToken,true, user.getRole()));
    }

    @PostMapping("/tokens/custom")
    public ResponseEntity<LoginResponse> generateCustomToken(
            @RequestParam String accessToken,
            @RequestParam Long newExpirationMinutes
    ){
        User user = authTokenProvider.parseUser(accessToken);
        AccessToken newAccessToken = createNewCustomAccessToken(user, newExpirationMinutes);
        return ResponseEntity.status(OK).body(LoginResponse.of(newAccessToken,new RefreshToken("refresh"),true, user.getRole()));
    }

    private AccessToken createNewCustomAccessToken(
            User user,
            Long newExpirationMinutes
    ) {
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

    @Transactional
    @PostMapping("/follows/setup")
    public ResponseEntity<Void> setupFollowRelations() {
        for (long i = MUTUAL_FOLLOWER_FIRST_ID; i <= MUTUAL_FOLLOWER_LAST_ID; i++) {
            follow(MAIN_USER_ID, i);
            follow(i, MAIN_USER_ID);
        }
        for (long i = ONE_WAY_FOLLOWER_FIRST_ID; i <= ONE_WAY_FOLLOWER_LAST_ID; i++) {
            follow(i, MAIN_USER_ID);
        }
        return ResponseEntity.status(OK).build();
    }

    @Transactional
    @PostMapping("/events/notice-created")
    public ResponseEntity<Void> publishNoticeCreatedEvent(
            @RequestParam long noticeId,
            @RequestParam String title
    ) {
        publisher.publishEvent(new NoticeCreatedEvent(noticeId, title));
        return ResponseEntity.status(OK).build();
    }

    private void follow(
            long followerId,
            long followeeId
    ) {
        if (!friendRepository.existsByFollowerIdAndFolloweeId(followerId, followeeId)) {
            friendRepository.save(Friend.create(followerId, followeeId));
        }
    }
}
