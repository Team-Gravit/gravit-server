package gravit.code.auth.jwt;

import gravit.code.auth.domain.LoginUser;
import gravit.code.auth.domain.Subject;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.core.Authentication;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Field;
import java.time.Duration;
import java.util.Map;

import static org.hibernate.validator.internal.util.Contracts.assertNotNull;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.annotation.DirtiesContext.ClassMode.AFTER_CLASS;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class JwtProviderTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtProvider jwtProvider;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = User.create("test@test.com","kakao_123123","kang","@qwd123",1, Role.USER);
        userRepository.save(testUser);
    }

    @Test
    void UserId_로_AccessToken_을_생성합니다() {
        // given
        Subject subject = new Subject(testUser.getId().toString());
        Role role = Role.USER;
        Duration duration = Duration.ofHours(2);

        // when
        String accessToken = jwtProvider.generateToken(subject, Map.of("role", role.name()),duration);

        // then
        assertNotNull(accessToken);
    }

    @Test
    void AccessToken_에서_User_정보를_가져옵니다() {
        // given
        // when
        Authentication authentication = jwtProvider.getAuthentication(testUser);

        // then
        assertNotNull(authentication);
        LoginUser principal = (LoginUser) authentication.getPrincipal();
        assertEquals(principal.getId(), testUser.getId());
    }

    /** 로직이 변경되었다.**/
//    @Test
//    void 유효하지_않는_User_의_토큰이라면_예외를_던집니다() {
//        // given
//        User wrongUser = User.create("wrong", "wrong", "wrong", "wrong", 1, Role.USER);
//
//        // when
//        // then
//        assertThrows(RestApiException.class, () -> jwtProvider.getAuthentication(wrongUser));
//    }

    @Test
    void 토큰에서_userId_를_추출합니다() {
        // given
        Subject subject = new Subject(testUser.getId().toString());
        Role role = Role.USER;
        Duration duration = Duration.ofHours(2);

        String accessToken = jwtProvider.generateToken(subject, Map.of("role", role.name()), duration);

        // when
        Long resultUserId = jwtProvider.getUserId(accessToken);

        // then
        assertEquals(testUser.getId(), resultUserId);
    }

    @Test
    void 유효기간이_지나지않은_토큰은_예외를_던지지_않습니다() {
        // given
        Subject subject = new Subject(testUser.getId().toString());
        Role role = Role.USER;
        Duration duration = Duration.ofHours(2);
        String accessToken = jwtProvider.generateToken(subject, Map.of("role", role.name()), duration);

        // when
        // then
        assertDoesNotThrow(() -> jwtProvider.validateToken(accessToken));
    }

    @Nested
    @DirtiesContext(classMode = AFTER_CLASS)
    class ExpiredTokenTests {

        @Test
        void 유효기간이_지난_토큰이라면_예외를_리턴합니다(){
            // given
            Subject subject = new Subject(testUser.getId().toString());
            Role role = Role.USER;
            Duration duration = Duration.ofHours(0);

            String accessToken = jwtProvider.generateToken(subject, Map.of("role", role.name()), duration);

            // when
            // then
            assertThrows(RestApiException.class, () -> jwtProvider.validateToken(accessToken));
        }

        @Test
        void 만료된_토큰에서_userId_를_추출하려고_하면_예외를_리턴합니다()  {
            // given
            Subject subject = new Subject(testUser.getId().toString());
            Role role = Role.USER;
            Duration duration = Duration.ofHours(0);

            String accessToken = jwtProvider.generateToken(subject, Map.of("role", role.name()),duration);

            // when
            // then
            assertThrows(RestApiException.class, () -> jwtProvider.getUserId(accessToken));
        }
    }
}