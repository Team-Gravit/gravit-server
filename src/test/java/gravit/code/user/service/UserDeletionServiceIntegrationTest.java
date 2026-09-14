package gravit.code.user.service;

import gravit.code.admin.repository.AdminUserRepository;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.domain.InterviewSessionTopic;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interview.repository.InterviewSessionTopicRepository;
import gravit.code.interviewFeedback.domain.InterviewFeedback;
import gravit.code.interviewFeedback.repository.InterviewFeedbackRepository;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.league.domain.League;
import gravit.code.league.fixture.LeagueFixture;
import gravit.code.season.domain.Season;
import gravit.code.season.fixture.SeasonFixture;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserStatus;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.service.port.MailAuthCodeStore;
import gravit.code.user.service.port.MailSender;
import gravit.code.userLeague.fixture.UserLeagueFixture;
import gravit.code.userLeague.service.port.LeagueRankingStore;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import static gravit.code.global.exception.domain.CustomErrorCode.*;
import static gravit.code.interview.fixture.InterviewSessionFixture.미제출_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.답변한_답안;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.세션_주제;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.피드백;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@TCSpringBootTest
class UserDeletionServiceIntegrationTest {

    private static final long NON_EXISTENT_USER_ID = 999L;
    private static final long QUESTION_ID = 100L;
    private static final int FIRST_DISPLAY_ORDER = 1;
    private static final String ANSWER_CONTENT = "TCP는 연결 지향 프로토콜입니다.";
    private static final LocalDateTime ANSWERED_AT = LocalDateTime.of(2025, 8, 5, 12, 0);
    private static final int ACCURACY_SCORE = 14;
    private static final int STRUCTURE_SCORE = 3;
    private static final int CLARITY_SCORE = 3;
    private static final String IMPROVEMENT_SUGGESTION = "핵심을 먼저 말한 좋은 답변입니다.";
    private static final String RESTORED_HANDLE = "restored1";
    private static final long LOCK_WAIT_MILLIS = 500L;
    private static final long TIMEOUT_SECONDS = 10L;

    @Autowired
    private UserDeletionService userDeletionService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AdminUserRepository adminUserRepository;

    @Autowired
    private TransactionTemplate transactionTemplate;

    @Autowired
    private LeagueRankingStore leagueRankingStore;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private SeasonFixture seasonFixture;

    @Autowired
    private LeagueFixture leagueFixture;

    @Autowired
    private UserLeagueFixture userLeagueFixture;

    @Autowired
    private MailAuthCodeStore mailAuthCodeStore;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewSessionTopicRepository interviewSessionTopicRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewFeedbackRepository interviewFeedbackRepository;

    @MockitoBean
    private MailSender mailSender;

    private User 탈퇴_회원(int index) {
        User user = userFixture.일반_유저(index);
        userRepository.deleteById(user.getId());
        return user;
    }

    private void 대기(CountDownLatch latch) {
        try {
            if (!latch.await(TIMEOUT_SECONDS, TimeUnit.SECONDS)) {
                throw new IllegalStateException("래치 대기 시간 초과");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException(e);
        }
    }

    private boolean 끝나지_않고_대기_중인지(Future<?> future) throws Exception {
        try {
            future.get(LOCK_WAIT_MILLIS, TimeUnit.MILLISECONDS);
            return false;
        } catch (TimeoutException e) {
            return true;
        }
    }

    @Nested
    @DisplayName("회원 탈퇴 메일을 요청할 때")
    class RequestDeleteMail {

        @Test
        void 유효한_유저와_dest이면_메일을_발송한다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            userDeletionService.requestDeleteMailWithMailAuthCode(user.getId(), "local");

            // then
            verify(mailSender, times(1)).sendEmailWithDeleteLink(any(), any(), any(), any());
        }

        @Test
        void 존재하지_않는_유저이면_예외를_던진다() {
            // given
            long nonExistentUserId = 999L;

            // when & then
            assertThatThrownBy(() -> userDeletionService.requestDeleteMailWithMailAuthCode(nonExistentUserId, "local"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(USER_NOT_FOUND);
        }

        @Test
        void 유효하지_않은_dest이면_예외를_던진다() {
            // given
            User user = userFixture.일반_유저(1);

            // when & then
            assertThatThrownBy(() -> userDeletionService.requestDeleteMailWithMailAuthCode(user.getId(), "invalid-dest"))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(DEST_NOT_VALID);
        }
    }

    @Nested
    @DisplayName("탈퇴 유저 데이터를 완전 삭제(cleanUserDeletion)할 때")
    class CleanUserDeletion {

        @Test
        @DisplayName("연관 데이터가 없어도 전체 삭제 SQL이 실제 스키마에서 정상 실행되고 유저가 삭제된다")
        void 연관데이터_없이_정상_삭제() {
            // given
            User user = 탈퇴_회원(1);

            // when — 전체 CTE(DELETE 문)를 실제 DB에 실행: 존재하지 않는 테이블/문법 오류가 있으면 여기서 실패한다
            boolean cleaned = userDeletionService.cleanUserDeletion(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(cleaned).isTrue();
                softly.assertThat(userRepository.findByProviderId(user.getProviderId())).isEmpty();
            });
        }

        @Test
        void 탈퇴_회원의_면접_기록만_삭제하고_다른_회원의_기록은_남긴다() {
            // given
            User target = 탈퇴_회원(1);
            User other = userFixture.일반_유저(2);

            InterviewSession completedSession = interviewSessionRepository.save(
                    상태_세션(target.getId(), InterviewSessionStatus.COMPLETED));
            InterviewSession inProgressSession = interviewSessionRepository.save(
                    상태_세션(target.getId(), InterviewSessionStatus.IN_PROGRESS));
            InterviewSessionTopic topic = interviewSessionTopicRepository.save(
                    세션_주제(completedSession.getId(), InterviewTopic.NETWORK));
            InterviewAnswer answer = interviewAnswerRepository.save(
                    답변한_답안(completedSession.getId(), QUESTION_ID, FIRST_DISPLAY_ORDER, ANSWER_CONTENT, ANSWERED_AT));
            List<InterviewAnswer> pendingAnswers = interviewAnswerRepository.saveAll(
                    미제출_답안(inProgressSession.getId(), List.of(QUESTION_ID)));
            InterviewFeedback feedback = interviewFeedbackRepository.save(
                    피드백(answer.getId(), ACCURACY_SCORE, STRUCTURE_SCORE, CLARITY_SCORE, IMPROVEMENT_SUGGESTION));

            InterviewSession otherSession = interviewSessionRepository.save(
                    상태_세션(other.getId(), InterviewSessionStatus.COMPLETED));
            InterviewSessionTopic otherTopic = interviewSessionTopicRepository.save(
                    세션_주제(otherSession.getId(), InterviewTopic.NETWORK));
            InterviewAnswer otherAnswer = interviewAnswerRepository.save(
                    답변한_답안(otherSession.getId(), QUESTION_ID, FIRST_DISPLAY_ORDER, ANSWER_CONTENT, ANSWERED_AT));
            InterviewFeedback otherFeedback = interviewFeedbackRepository.save(
                    피드백(otherAnswer.getId(), ACCURACY_SCORE, STRUCTURE_SCORE, CLARITY_SCORE, IMPROVEMENT_SUGGESTION));

            // when
            userDeletionService.cleanUserDeletion(target.getId());

            // then
            List<Long> pendingAnswerIds = pendingAnswers.stream()
                    .map(InterviewAnswer::getId)
                    .toList();

            assertSoftly(softly -> {
                softly.assertThat(interviewSessionRepository.findAllById(
                        List.of(completedSession.getId(), inProgressSession.getId()))).isEmpty();
                softly.assertThat(interviewSessionTopicRepository.findById(topic.getId())).isEmpty();
                softly.assertThat(interviewAnswerRepository.findById(answer.getId())).isEmpty();
                softly.assertThat(interviewAnswerRepository.findAllById(pendingAnswerIds)).isEmpty();
                softly.assertThat(interviewFeedbackRepository.findById(feedback.getId())).isEmpty();

                softly.assertThat(interviewSessionRepository.findById(otherSession.getId())).isPresent();
                softly.assertThat(interviewSessionTopicRepository.findById(otherTopic.getId())).isPresent();
                softly.assertThat(interviewAnswerRepository.findById(otherAnswer.getId())).isPresent();
                softly.assertThat(interviewFeedbackRepository.findById(otherFeedback.getId())).isPresent();
            });
        }

        @Test
        void 활성_회원이면_지우지_않고_false를_돌려준다() {
            // given
            User user = userFixture.일반_유저(1);
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(user.getId(), InterviewSessionStatus.COMPLETED));

            // when
            boolean cleaned = userDeletionService.cleanUserDeletion(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(cleaned).isFalse();
                softly.assertThat(userRepository.findById(user.getId())).isPresent();
                softly.assertThat(interviewSessionRepository.findById(session.getId())).isPresent();
            });
        }

        @Test
        void 탈퇴_후_복구한_회원이면_지우지_않고_false를_돌려준다() {
            // given
            User user = 탈퇴_회원(1);
            userService.restoreUser(user.getProviderId());

            // when
            boolean cleaned = userDeletionService.cleanUserDeletion(user.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(cleaned).isFalse();
                softly.assertThat(userRepository.findById(user.getId())).isPresent();
            });
        }

        @Test
        void 없는_회원이면_false를_돌려준다() {
            // when
            boolean cleaned = userDeletionService.cleanUserDeletion(NON_EXISTENT_USER_ID);

            // then
            assertThat(cleaned).isFalse();
        }

        @Test
        void 복구가_행을_먼저_잠그면_복구가_커밋된_뒤_삭제를_건너뛴다() throws Exception {
            // given
            User user = 탈퇴_회원(1);
            CountDownLatch restoreLocked = new CountDownLatch(1);
            CountDownLatch restoreReleased = new CountDownLatch(1);
            ExecutorService executor = Executors.newFixedThreadPool(2);

            try {
                Future<?> restore = executor.submit(() -> transactionTemplate.executeWithoutResult(status -> {
                    adminUserRepository.restoreStatusById(user.getId(), UserStatus.ACTIVE.name(), RESTORED_HANDLE);
                    restoreLocked.countDown();
                    대기(restoreReleased);
                }));
                대기(restoreLocked);

                // when
                Future<Boolean> deletion = executor.submit(() -> userDeletionService.cleanUserDeletion(user.getId()));
                boolean waitedForRestore = 끝나지_않고_대기_중인지(deletion);

                restoreReleased.countDown();
                restore.get(TIMEOUT_SECONDS, TimeUnit.SECONDS);
                boolean cleaned = deletion.get(TIMEOUT_SECONDS, TimeUnit.SECONDS);

                // then
                assertSoftly(softly -> {
                    softly.assertThat(waitedForRestore).isTrue();
                    softly.assertThat(cleaned).isFalse();
                    softly.assertThat(userRepository.findById(user.getId())).isPresent();
                });
            } finally {
                restoreReleased.countDown();
                executor.shutdownNow();
            }
        }
    }

    @Nested
    @DisplayName("메일 인증 코드로 회원 탈퇴를 확인할 때")
    class ConfirmDeleteByMailAuthCode {

        @Test
        void 유효한_인증코드이면_회원을_탈퇴_처리한다() {
            // given
            User user = userFixture.일반_유저(1);
            String authCode = "validauthcode123";
            mailAuthCodeStore.save(authCode, user.getId(), 180);

            // when
            userDeletionService.confirmDeleteByMailAuthCode(authCode);

            // then
            assertThat(userRepository.findById(user.getId())).isEmpty();
        }

        @Test
        void 유효하지_않은_인증코드이면_예외를_던진다() {
            // given
            String invalidAuthCode = "invalid-code";

            // when & then
            assertThatThrownBy(() -> userDeletionService.confirmDeleteByMailAuthCode(invalidAuthCode))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INVALID_MAIL_AUTH_CODE);
        }

        @Test
        void 탈퇴하면_랭킹_저장소에서_제거된다() {
            // given
            User user = userFixture.일반_유저(1);
            Season season = seasonFixture.진행중인_시즌("S1");
            League 브론즈3 = leagueFixture.브론즈_3();
            userLeagueFixture.참여(user, season, 브론즈3, 50);
            leagueRankingStore.put(season.getId(), 브론즈3.getId(), user.getId(), 50);

            String authCode = "deleteauthcode123";
            mailAuthCodeStore.save(authCode, user.getId(), 180);

            // when
            userDeletionService.confirmDeleteByMailAuthCode(authCode);

            // then
            assertThat(leagueRankingStore.findRank(season.getId(), 브론즈3.getId(), user.getId()))
                    .isEmpty();
        }
    }

}
