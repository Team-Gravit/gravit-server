package gravit.code.user.service;

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

import java.time.LocalDateTime;
import java.util.List;

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

    @Autowired
    private UserDeletionService userDeletionService;

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

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
            User user = userFixture.일반_유저(1);

            // when — 전체 CTE(DELETE 문)를 실제 DB에 실행: 존재하지 않는 테이블/문법 오류가 있으면 여기서 실패한다
            userDeletionService.cleanUserDeletion(user.getId());

            // then
            assertThat(userRepository.findById(user.getId())).isEmpty();
        }

        @Test
        void 탈퇴_회원의_면접_기록만_삭제하고_다른_회원의_기록은_남긴다() {
            // given
            User target = userFixture.일반_유저(1);
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
    }

    @Nested
    @DisplayName("탈퇴 상태를 확인할 때")
    class IsWithdrawn {

        @Test
        void 탈퇴한_회원이면_true를_돌려준다() {
            // given
            User user = userFixture.일반_유저(1);
            userRepository.deleteById(user.getId());

            // when
            boolean withdrawn = userDeletionService.isWithdrawn(user.getId());

            // then
            assertThat(withdrawn).isTrue();
        }

        @Test
        void 활성_회원이면_false를_돌려준다() {
            // given
            User user = userFixture.일반_유저(1);

            // when
            boolean withdrawn = userDeletionService.isWithdrawn(user.getId());

            // then
            assertThat(withdrawn).isFalse();
        }

        @Test
        void 탈퇴_후_복구한_회원이면_false를_돌려준다() {
            // given
            User user = userFixture.일반_유저(1);
            userRepository.deleteById(user.getId());
            userService.restoreUser(user.getProviderId());

            // when
            boolean withdrawn = userDeletionService.isWithdrawn(user.getId());

            // then
            assertThat(withdrawn).isFalse();
        }

        @Test
        void 없는_회원이면_false를_돌려준다() {
            // when
            boolean withdrawn = userDeletionService.isWithdrawn(NON_EXISTENT_USER_ID);

            // then
            assertThat(withdrawn).isFalse();
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
