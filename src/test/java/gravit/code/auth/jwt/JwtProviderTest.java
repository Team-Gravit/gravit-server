package gravit.code.auth.jwt;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.core.Authentication;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Field;
import java.time.LocalDateTime;

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
        testUser = User.create("test@test.com","kakao_123123","kang","@qwd123",1, LocalDateTime.now());
        userRepository.save(testUser);
    }

    @Test
    void UserId_로_AccessToken_을_생성합니다() {
        // given
        Long userId = testUser.getId();

        // when
        String accessToken = jwtProvider.createAccessToken(userId);

        // then
        assertNotNull(accessToken);
    }

    @Test
    void AccessToken_에서_User_정보를_가져옵니다() {
        // given
        Long userId = testUser.getId();
        String accessToken = jwtProvider.createAccessToken(userId);

        // when
        Authentication authentication = jwtProvider.getAuthUser(accessToken);

        // then
        assertNotNull(authentication);
        LoginUser principal = (LoginUser) authentication.getPrincipal();
        assertEquals(principal.getId(), testUser.getId());
    }

    @Test
    void 유효하지_않는_User_의_토큰이라면_예외를_던집니다() {
        // given
        Long wrongUserId = 999L;
        String accessToken = jwtProvider.createAccessToken(wrongUserId);

        // when
        // then
        assertThrows(RestApiException.class, () -> jwtProvider.getAuthUser(accessToken));
    }

    @Test
    void 토큰에서_userId_를_추출합니다() {
        // given
        Long userId = testUser.getId();
        String accessToken = jwtProvider.createAccessToken(userId);

        // when
        Long resultUserId = jwtProvider.getUserId(accessToken);

        // then
        assertEquals(userId, resultUserId);
    }

    @Test
    void 유효기간이_지나지않은_토큰은_true_를_리턴합니다() {
        // given
        Long userId = testUser.getId();
        String accessToken = jwtProvider.createAccessToken(userId);

        // when
        boolean result = jwtProvider.isValidToken(accessToken);

        // then
        assertTrue(result);
    }

    @Nested
    @DirtiesContext(classMode = AFTER_CLASS)
    class ExpiredTokenTests {

        @BeforeEach
        void setUp() throws NoSuchFieldException, IllegalAccessException {
            Field validTimeField = JwtProvider.class.getDeclaredField("validTime");
            validTimeField.setAccessible(true);
            validTimeField.setInt(jwtProvider,1);
        }

        @Test
        void 유효기간이_지난_토큰이라면_예외를_리턴합니다() throws InterruptedException {
            // given
            Long userId = testUser.getId();
            String accessToken = jwtProvider.createAccessToken(userId);

            Thread.sleep(3);

            // when
            // then
            assertThrows(RestApiException.class, () -> jwtProvider.isValidToken(accessToken));
        }

        @Test
        void 만료된_토큰에서_userId_를_추출하려고_하면_예외를_리턴합니다() throws InterruptedException {
            // given
            Long userId = testUser.getId();
            String accessToken = jwtProvider.createAccessToken(userId);

            Thread.sleep(3);

            // when
            // then
            assertThrows(RestApiException.class, () -> jwtProvider.getUserId(accessToken));
        }
    }
}