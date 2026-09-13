package gravit.code.user.infrastructure;

import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.UserService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doThrow;

@TCSpringBootTest
class UserXpInterviewRetryTargetIntegrationTest {

    private static final long NON_EXISTENT_USER_ID = 999L;
    private static final int REWARD_POINTS = 30;
    private static final String TRANSIENT_ERROR_MESSAGE = "DB 커넥션 실패";

    @Autowired
    private UserXpInterviewRetryTarget userXpInterviewRetryTarget;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @MockitoSpyBean
    private UserService userService;

    private Map<String, String> 재시도_페이로드(long userId) {
        return Map.of(
                "userId", String.valueOf(userId),
                "xp", String.valueOf(REWARD_POINTS)
        );
    }

    @Nested
    @DisplayName("재시도 큐 항목을 재처리할 때")
    class Reprocess {

        @Test
        void 큐_키는_리스너가_적재하는_키와_같다() {
            // when
            String queueKey = userXpInterviewRetryTarget.queueKey();

            // then
            assertThat(queueKey).isEqualTo("user-xp-interview-retry");
        }

        @Test
        void 리스너가_적재한_페이로드로_XP가_누적된다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            userXpInterviewRetryTarget.reprocess(재시도_페이로드(user.getId()));

            // then
            User updated = userRepository.findById(user.getId()).orElseThrow();
            assertThat(updated.getLevel().getXp()).isEqualTo(REWARD_POINTS);
        }

        @Test
        void 유저가_없으면_예외_없이_재시도를_끝낸다() {
            // when & then
            assertThatCode(() -> userXpInterviewRetryTarget.reprocess(재시도_페이로드(NON_EXISTENT_USER_ID)))
                    .doesNotThrowAnyException();
        }

        @Test
        void 일시적_오류는_다시_던져_재적재되게_한다() {
            // given
            User user = userFixture.일반_유저(1);
            doThrow(new RuntimeException(TRANSIENT_ERROR_MESSAGE)).when(userService).addXp(user.getId(), REWARD_POINTS);

            // when & then
            assertThatThrownBy(() -> userXpInterviewRetryTarget.reprocess(재시도_페이로드(user.getId())))
                    .isInstanceOf(RuntimeException.class)
                    .hasMessage(TRANSIENT_ERROR_MESSAGE);
        }
    }
}
