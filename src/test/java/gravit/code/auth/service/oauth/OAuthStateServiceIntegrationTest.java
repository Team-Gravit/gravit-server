package gravit.code.auth.service.oauth;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;

import java.util.concurrent.TimeUnit;

import static gravit.code.global.exception.domain.CustomErrorCode.OAUTH_STATE_INVALID;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class OAuthStateServiceIntegrationTest {

    private static final String KEY_PREFIX = "oauthState:";
    private static final String GOOGLE = "google";
    private static final String KAKAO = "kakao";

    @Autowired
    private OAuthStateService oAuthStateService;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Nested
    @DisplayName("state를 발급할 때")
    class Issue {

        @Test
        void 제공자_이름을_값으로_10분_동안_저장한다() {
            // when
            String state = oAuthStateService.issue(GOOGLE);

            // then
            String key = KEY_PREFIX + state;
            Long ttlSeconds = redisTemplate.getExpire(key, TimeUnit.SECONDS);

            assertSoftly(softly -> {
                softly.assertThat(redisTemplate.opsForValue().get(key)).isEqualTo(GOOGLE);
                softly.assertThat(ttlSeconds).isBetween(590L, 600L);
            });
        }

        @Test
        void 발급할_때마다_다른_state를_만든다() {
            // when
            String first = oAuthStateService.issue(GOOGLE);
            String second = oAuthStateService.issue(GOOGLE);

            // then
            assertSoftly(softly -> {
                softly.assertThat(first).isNotBlank();
                softly.assertThat(second).isNotEqualTo(first);
            });
        }
    }

    @Nested
    @DisplayName("state를 검증할 때")
    class Verify {

        @Test
        void 발급한_state와_같은_제공자면_통과하고_state를_지운다() {
            // given
            String state = oAuthStateService.issue(GOOGLE);

            // when & then
            assertThatCode(() -> oAuthStateService.verify(GOOGLE, state)).doesNotThrowAnyException();

            assertThat(redisTemplate.hasKey(KEY_PREFIX + state)).isFalse();
        }

        @Test
        void 같은_state를_두_번째로_쓰면_예외를_던진다() {
            // given
            String state = oAuthStateService.issue(GOOGLE);
            oAuthStateService.verify(GOOGLE, state);

            // when & then
            assertThatThrownBy(() -> oAuthStateService.verify(GOOGLE, state))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_STATE_INVALID);
        }

        @Test
        void 다른_제공자용으로_발급한_state면_예외를_던지고_state도_지운다() {
            // given
            String state = oAuthStateService.issue(GOOGLE);

            // when & then
            assertThatThrownBy(() -> oAuthStateService.verify(KAKAO, state))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_STATE_INVALID);

            assertThat(redisTemplate.hasKey(KEY_PREFIX + state)).isFalse();
        }

        @Test
        void 발급하지_않은_state면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> oAuthStateService.verify(GOOGLE, "not-issued-state"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_STATE_INVALID);
        }

        @Test
        void state가_null이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> oAuthStateService.verify(GOOGLE, null))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_STATE_INVALID);
        }

        @Test
        void state가_공백이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> oAuthStateService.verify(GOOGLE, " "))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(OAUTH_STATE_INVALID);
        }
    }
}
