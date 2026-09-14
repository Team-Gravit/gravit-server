package gravit.code.user.facade;

import gravit.code.global.event.retry.RetryEventPublisher;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.UserDeletionService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;

import java.util.List;
import java.util.Map;

import static gravit.code.interview.fixture.InterviewAudioS3Fixture.권한_거부;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.삭제_성공;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.세션_접두사;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_목록;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_키;
import static gravit.code.interview.fixture.InterviewSessionFixture.미제출_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

@TCSpringBootTest
class UserDeletionFacadeIntegrationTest {

    private static final long NON_EXISTENT_USER_ID = 999L;
    private static final long QUESTION_ID = 100L;
    private static final String RETRY_QUEUE_KEY = "interview-audio-deletion-retry";
    private static final String SESSION_ID_FIELD = "sessionId";
    private static final String DB_ERROR_MESSAGE = "DB 커넥션 실패";

    @Autowired
    private UserDeletionFacade userDeletionFacade;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

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

    private InterviewSession 음성_세션(long userId) {
        InterviewSession session = interviewSessionRepository.save(진행중_세션(userId, InterviewInputType.VOICE));
        interviewAnswerRepository.saveAll(미제출_답안(session.getId(), List.of(QUESTION_ID)));
        return session;
    }

    @Nested
    @DisplayName("탈퇴 회원을 실제 삭제할 때")
    class CleanUserDeletion {

        @Test
        void 기록을_지운_뒤_삭제_전에_모은_세션의_음성을_지운다() {
            // given
            User user = 탈퇴_회원(1);
            InterviewSession session = 음성_세션(user.getId());
            doReturn(음성_목록(음성_키(session.getId(), 1))).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));
            doReturn(삭제_성공()).when(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            // when
            boolean cleaned = userDeletionFacade.cleanUserDeletion(user.getId());

            // then
            InOrder inOrder = inOrder(userDeletionService, s3Client);
            inOrder.verify(userDeletionService).cleanUserDeletion(user.getId());
            inOrder.verify(s3Client).listObjectsV2(any(ListObjectsV2Request.class));

            ArgumentCaptor<ListObjectsV2Request> listCaptor = ArgumentCaptor.forClass(ListObjectsV2Request.class);
            verify(s3Client).listObjectsV2(listCaptor.capture());
            verify(s3Client).deleteObjects(any(DeleteObjectsRequest.class));

            assertSoftly(softly -> {
                softly.assertThat(cleaned).isTrue();
                softly.assertThat(userRepository.findByProviderId(user.getProviderId())).isEmpty();
                softly.assertThat(interviewSessionRepository.findById(session.getId())).isEmpty();
                softly.assertThat(interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(session.getId())).isEmpty();
                softly.assertThat(listCaptor.getValue().prefix()).isEqualTo(세션_접두사(session.getId()));
            });
        }

        @Test
        void 음성_삭제가_실패해도_기록은_지우고_실패한_세션을_재시도_큐에_적재한다() {
            // given
            User user = 탈퇴_회원(1);
            InterviewSession session = 음성_세션(user.getId());
            doThrow(권한_거부()).when(s3Client).listObjectsV2(any(ListObjectsV2Request.class));

            // when
            boolean cleaned = userDeletionFacade.cleanUserDeletion(user.getId());

            // then
            verify(retryEventPublisher).publish(RETRY_QUEUE_KEY, Map.of(SESSION_ID_FIELD, String.valueOf(session.getId())));

            assertSoftly(softly -> {
                softly.assertThat(cleaned).isTrue();
                softly.assertThat(userRepository.findByProviderId(user.getProviderId())).isEmpty();
                softly.assertThat(interviewSessionRepository.findById(session.getId())).isEmpty();
            });
        }

        @Test
        void DB_삭제가_실패하면_예외를_던지고_음성은_건드리지_않는다() {
            // given
            User user = 탈퇴_회원(1);
            InterviewSession session = 음성_세션(user.getId());
            doThrow(new RuntimeException(DB_ERROR_MESSAGE)).when(userDeletionService).cleanUserDeletion(user.getId());

            // when & then
            assertThatThrownBy(() -> userDeletionFacade.cleanUserDeletion(user.getId()))
                    .isInstanceOf(RuntimeException.class)
                    .hasMessage(DB_ERROR_MESSAGE);

            verifyNoInteractions(s3Client, retryEventPublisher);
            assertThat(interviewSessionRepository.findById(session.getId())).isPresent();
        }

        @Test
        void 활성_회원이면_지우지_않고_false를_돌려준다() {
            // given
            User user = userFixture.일반_유저(1);
            InterviewSession session = 음성_세션(user.getId());

            // when
            boolean cleaned = userDeletionFacade.cleanUserDeletion(user.getId());

            // then
            verifyNoInteractions(s3Client, retryEventPublisher);

            assertSoftly(softly -> {
                softly.assertThat(cleaned).isFalse();
                softly.assertThat(userRepository.findById(user.getId())).isPresent();
                softly.assertThat(interviewSessionRepository.findById(session.getId())).isPresent();
            });
        }

        @Test
        void 이미_실제_삭제된_회원이면_false를_돌려준다() {
            // when
            boolean cleaned = userDeletionFacade.cleanUserDeletion(NON_EXISTENT_USER_ID);

            // then
            verifyNoInteractions(s3Client, retryEventPublisher);
            assertThat(cleaned).isFalse();
        }
    }
}
