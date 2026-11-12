package gravit.code.user.batch;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.infrastructure.RedisUserCleanManager;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.UserDeletionService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;

import java.util.Map;

import static gravit.code.interview.fixture.InterviewAudioS3Fixture.권한_거부;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class UserCleanSchedulerIntegrationTest {

    private static final String DUE_KEY = "user:clean:due";
    private static final double DUE_SCORE = 0;
    private static final String RETRY_QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";
    private static final String DB_ERROR_MESSAGE = "DB 커넥션 실패";

    @Autowired
    private UserCleanScheduler userCleanScheduler;

    @Autowired
    private RedisUserCleanManager cleanManager;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @MockitoBean
    private S3Client s3Client;

    @MockitoBean
    private RetryEventPublisher retryEventPublisher;

    @MockitoSpyBean
    private UserDeletionService userDeletionService;

    private User 탈퇴_회원(int index) {
        User user = userFixture.일반_유저(index);
        userRepository.deleteById(user.getId());
        return user;
    }

    private void 삭제_예약(long userId) {
        redisTemplate.opsForZSet().add(DUE_KEY, String.valueOf(userId), DUE_SCORE);
    }

    @Nested
    @DisplayName("도래한 삭제 예약을 처리할 때")
    class CleanUsers {

        @Test
        void 탈퇴_회원을_삭제하고_예약을_지운다() {
            // given
            User user = 탈퇴_회원(1);
            삭제_예약(user.getId());

            // when
            userCleanScheduler.cleanUsers();

            // then
            assertSoftly(softly -> {
                softly.assertThat(cleanManager.allDueUserIds()).isEmpty();
                softly.assertThat(userRepository.findByProviderId(user.getProviderId())).isEmpty();
            });
        }

        @Test
        void 음성_삭제가_실패해도_회원을_삭제하고_예약을_지운다() {
            // given
            User user = 탈퇴_회원(1);
            InterviewSession session = interviewSessionRepository.save(진행중_세션(user.getId(), InterviewInputType.VOICE));
            doThrow(권한_거부()).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));
            삭제_예약(user.getId());

            // when
            userCleanScheduler.cleanUsers();

            // then
            verify(retryEventPublisher).publish(RETRY_QUEUE_KEY, Map.of(SESSION_ID_FIELD, String.valueOf(session.getId())));

            assertSoftly(softly -> {
                softly.assertThat(cleanManager.allDueUserIds()).isEmpty();
                softly.assertThat(userRepository.findByProviderId(user.getProviderId())).isEmpty();
            });
        }

        @Test
        void DB_삭제가_실패하면_예약을_남긴다() {
            // given
            User user = 탈퇴_회원(1);
            doThrow(new RuntimeException(DB_ERROR_MESSAGE)).when(userDeletionService).cleanUserDeletion(user.getId());
            삭제_예약(user.getId());

            // when
            userCleanScheduler.cleanUsers();

            // then
            assertSoftly(softly -> {
                softly.assertThat(cleanManager.allDueUserIds()).containsExactly(user.getId());
                softly.assertThat(userRepository.findByProviderId(user.getProviderId())).isPresent();
            });
        }

        @Test
        void 활성_회원이면_삭제하지_않고_예약만_지운다() {
            // given
            User user = userFixture.일반_유저(1);
            삭제_예약(user.getId());

            // when
            userCleanScheduler.cleanUsers();

            // then
            assertSoftly(softly -> {
                softly.assertThat(cleanManager.allDueUserIds()).isEmpty();
                softly.assertThat(userRepository.findById(user.getId())).isPresent();
            });
        }

        @Test
        void 한_회원의_DB_삭제가_실패해도_다음_회원을_처리한다() {
            // given
            User failedUser = 탈퇴_회원(1);
            User cleanedUser = 탈퇴_회원(2);
            doThrow(new RuntimeException(DB_ERROR_MESSAGE)).when(userDeletionService).cleanUserDeletion(failedUser.getId());
            삭제_예약(failedUser.getId());
            삭제_예약(cleanedUser.getId());

            // when
            userCleanScheduler.cleanUsers();

            // then
            assertSoftly(softly -> {
                softly.assertThat(cleanManager.allDueUserIds()).containsExactly(failedUser.getId());
                softly.assertThat(userRepository.findByProviderId(failedUser.getProviderId())).isPresent();
                softly.assertThat(userRepository.findByProviderId(cleanedUser.getProviderId())).isEmpty();
            });
        }
    }
}
