package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewAnswerStatus;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.request.InterviewAnswerSubmitRequest;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interviewFeedback.repository.InterviewFeedbackRepository;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.repository.InterviewQuestionConceptRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.support.StubInterviewGradingClient;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_ALREADY_SUBMITTED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_ORDER_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_GRADING;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_SCORE_INVALID;
import static gravit.code.interview.fixture.InterviewSessionFixture.답안_요청;
import static gravit.code.interview.fixture.InterviewSessionFixture.미제출_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.음성_답안_요청;
import static gravit.code.interview.fixture.InterviewSessionFixture.제출_요청;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.개념;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.문제;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.awaitility.Awaitility.await;

@TCSpringBootTest
class InterviewSessionCommandServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long UNKNOWN_SESSION_ID = 999L;
    private static final long UNIT_ID = 11L;
    private static final int QUESTION_COUNT = 5;
    private static final int ANSWERED_ACCURACY = 14;
    private static final int ANSWERED_DELIVERY = 6;
    private static final int FIRST_GRADING_ATTEMPT = 1;
    private static final String BLANK_CONTENT = "   ";
    private static final String AUDIO_KEY = "interview/1/1.m4a";
    private static final Duration GRADING_TIMEOUT = Duration.ofSeconds(10);
    private static final List<InterviewTopic> TOPICS = List.of(
            InterviewTopic.DATA_STRUCTURE,
            InterviewTopic.ALGORITHM,
            InterviewTopic.DATABASE,
            InterviewTopic.OPERATING_SYSTEM,
            InterviewTopic.NETWORK
    );

    @Autowired
    private InterviewSessionCommandService interviewSessionCommandService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Autowired
    private InterviewQuestionConceptRepository interviewQuestionConceptRepository;

    @Autowired
    private InterviewFeedbackRepository interviewFeedbackRepository;

    @Autowired
    private StubInterviewGradingClient stubInterviewGradingClient;

    @Autowired
    private Clock clock;

    @BeforeEach
    void resetStub() {
        stubInterviewGradingClient.reset();
    }

    private List<Long> 저장된_문제_5개() {
        List<Long> questionIds = new ArrayList<>();
        for (InterviewTopic topic : TOPICS) {
            InterviewQuestion question = interviewQuestionRepository.save(문제(topic, UNIT_ID));
            interviewQuestionConceptRepository.save(
                    개념(question.getId(), topic.getDisplayName() + " 필수 개념", InterviewConceptType.ESSENTIAL, 1)
            );
            questionIds.add(question.getId());
        }
        return questionIds;
    }

    private InterviewSession 준비된_세션(InterviewInputType inputType) {
        InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, inputType));
        interviewAnswerRepository.saveAll(미제출_답안(session.getId(), 저장된_문제_5개()));
        return session;
    }

    private InterviewSession 세션(long sessionId) {
        return interviewSessionRepository.findById(sessionId).orElseThrow();
    }

    private List<InterviewAnswer> 답안들(long sessionId) {
        return interviewAnswerRepository.findAllBySessionIdOrderByDisplayOrderAsc(sessionId);
    }

    private void 채점_완료를_기다린다(long sessionId) {
        await().atMost(GRADING_TIMEOUT).untilAsserted(() ->
                assertThat(세션(sessionId).getStatus()).isNotEqualTo(InterviewSessionStatus.GRADING)
        );
    }

    @Nested
    @DisplayName("답안을 제출할 때")
    class Submit {

        @Test
        void 답안을_저장하고_채점_중으로_전이한_뒤_백그라운드_채점이_완료된다() {
            // given
            InterviewSession session = 준비된_세션(InterviewInputType.TEXT);
            List<InterviewAnswerSubmitRequest> requests = 제출_요청("답변 1", "답변 2", "답변 3", "답변 4", BLANK_CONTENT);
            LocalDateTime now = LocalDateTime.now(clock);

            // when
            InterviewSessionStatusResponse response = interviewSessionCommandService.submit(USER_ID, session.getId(), requests);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.sessionId()).isEqualTo(session.getId());
                softly.assertThat(response.status()).isEqualTo(InterviewSessionStatus.GRADING);
            });

            채점_완료를_기다린다(session.getId());

            List<InterviewAnswer> answers = 답안들(session.getId());
            InterviewSession graded = 세션(session.getId());
            assertSoftly(softly -> {
                softly.assertThat(answers).hasSize(QUESTION_COUNT);
                softly.assertThat(answers.subList(0, 4))
                        .allSatisfy(answer -> {
                            assertThat(answer.getStatus()).isEqualTo(InterviewAnswerStatus.ANSWERED);
                            assertThat(answer.getContent()).isEqualTo("답변 " + answer.getDisplayOrder());
                        });
                softly.assertThat(answers.get(4).getStatus()).isEqualTo(InterviewAnswerStatus.NO_RESPONSE);
                softly.assertThat(answers.get(4).getContent()).isNull();
                softly.assertThat(answers).allSatisfy(answer -> {
                    assertThat(answer.getAnsweredAt()).isEqualTo(now);
                    assertThat(answer.getAudioKey()).isNull();
                });

                softly.assertThat(graded.getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(graded.getEndedAt()).isEqualTo(now);
                softly.assertThat(graded.getGradingAttemptCount()).isEqualTo(FIRST_GRADING_ATTEMPT);
                softly.assertThat(graded.getAccuracyScore()).isEqualTo(ANSWERED_ACCURACY * 4);
                softly.assertThat(graded.getDeliveryScore()).isEqualTo(ANSWERED_DELIVERY * 4);

                softly.assertThat(interviewFeedbackRepository.count()).isEqualTo(QUESTION_COUNT);
                softly.assertThat(stubInterviewGradingClient.callCount()).isEqualTo(4);
            });
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // given
            List<InterviewAnswerSubmitRequest> requests = 제출_요청("1", "2", "3", "4", "5");

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.submit(USER_ID, UNKNOWN_SESSION_ID, requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 남의_세션이면_예외를_던진다() {
            // given
            InterviewSession session = 준비된_세션(InterviewInputType.TEXT);
            List<InterviewAnswerSubmitRequest> requests = 제출_요청("1", "2", "3", "4", "5");

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.submit(OTHER_USER_ID, session.getId(), requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }

        @ParameterizedTest
        @EnumSource(value = InterviewSessionStatus.class, names = {"GRADING", "GRADING_FAILED", "COMPLETED", "ABANDONED"})
        void 진행_중이_아닌_세션이면_예외를_던진다(InterviewSessionStatus status) {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, status));
            interviewAnswerRepository.saveAll(미제출_답안(session.getId(), 저장된_문제_5개()));
            List<InterviewAnswerSubmitRequest> requests = 제출_요청("1", "2", "3", "4", "5");

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.submit(USER_ID, session.getId(), requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        @Test
        void 이미_제출된_답안이_있으면_예외를_던지고_아무것도_바뀌지_않는다() {
            // given
            InterviewSession session = 준비된_세션(InterviewInputType.TEXT);
            InterviewAnswer submitted = 답안들(session.getId()).get(2);
            ReflectionTestUtils.setField(submitted, "status", InterviewAnswerStatus.ANSWERED);
            interviewAnswerRepository.save(submitted);
            List<InterviewAnswerSubmitRequest> requests = 제출_요청("1", "2", "3", "4", "5");

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.submit(USER_ID, session.getId(), requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_ALREADY_SUBMITTED);

            InterviewAnswer first = 답안들(session.getId()).get(0);
            assertSoftly(softly -> {
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.IN_PROGRESS);
                softly.assertThat(first.getStatus()).isEqualTo(InterviewAnswerStatus.PENDING);
                softly.assertThat(first.getAnsweredAt()).isNull();
                softly.assertThat(interviewFeedbackRepository.count()).isZero();
                softly.assertThat(stubInterviewGradingClient.callCount()).isZero();
            });
        }

        @Test
        void 문항_번호가_중복되면_예외를_던진다() {
            // given
            InterviewSession session = 준비된_세션(InterviewInputType.TEXT);
            List<InterviewAnswerSubmitRequest> requests = List.of(
                    답안_요청(1, "1"), 답안_요청(1, "중복"), 답안_요청(3, "3"), 답안_요청(4, "4"), 답안_요청(5, "5")
            );

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.submit(USER_ID, session.getId(), requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_ORDER_INVALID);
        }

        @Test
        void 텍스트_세션에_음성_키가_있으면_예외를_던진다() {
            // given
            InterviewSession session = 준비된_세션(InterviewInputType.TEXT);
            List<InterviewAnswerSubmitRequest> requests = List.of(
                    음성_답안_요청(1, "1", AUDIO_KEY), 답안_요청(2, "2"), 답안_요청(3, "3"), 답안_요청(4, "4"), 답안_요청(5, "5")
            );

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.submit(USER_ID, session.getId(), requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_INPUT_TYPE_MISMATCH);
        }

        @Test
        void 세션의_답안이_5건이_아니면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.TEXT));
            List<Long> questionIds = 저장된_문제_5개().subList(0, 4);
            interviewAnswerRepository.saveAll(미제출_답안(session.getId(), questionIds));
            List<InterviewAnswerSubmitRequest> requests = 제출_요청("1", "2", "3", "4", "5");

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.submit(USER_ID, session.getId(), requests))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_NOT_FOUND);
        }

        @Test
        void 음성_세션은_음성_키를_검증_없이_그대로_저장한다() {
            // given
            InterviewSession session = 준비된_세션(InterviewInputType.VOICE);
            List<InterviewAnswerSubmitRequest> requests = List.of(
                    음성_답안_요청(1, "1", AUDIO_KEY),
                    음성_답안_요청(2, "2", AUDIO_KEY),
                    음성_답안_요청(3, "3", AUDIO_KEY),
                    음성_답안_요청(4, "4", AUDIO_KEY),
                    음성_답안_요청(5, BLANK_CONTENT, null)
            );

            // when
            interviewSessionCommandService.submit(USER_ID, session.getId(), requests);
            채점_완료를_기다린다(session.getId());

            // then
            List<InterviewAnswer> answers = 답안들(session.getId());
            assertSoftly(softly -> {
                softly.assertThat(answers.subList(0, 4)).allSatisfy(answer -> assertThat(answer.getAudioKey()).isEqualTo(AUDIO_KEY));
                softly.assertThat(answers.get(4).getAudioKey()).isNull();
                softly.assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
            });
        }

        @Test
        void 판정이_실패하면_채점_실패로_전이하고_피드백을_저장하지_않는다() {
            // given
            InterviewSession session = 준비된_세션(InterviewInputType.TEXT);
            stubInterviewGradingClient.failAlways();
            List<InterviewAnswerSubmitRequest> requests = 제출_요청("1", "2", "3", "4", "5");
            LocalDateTime now = LocalDateTime.now(clock);

            // when
            interviewSessionCommandService.submit(USER_ID, session.getId(), requests);
            채점_완료를_기다린다(session.getId());

            // then
            InterviewSession failed = 세션(session.getId());
            assertSoftly(softly -> {
                softly.assertThat(failed.getStatus()).isEqualTo(InterviewSessionStatus.GRADING_FAILED);
                softly.assertThat(failed.getEndedAt()).isEqualTo(now);
                softly.assertThat(failed.getGradingAttemptCount()).isEqualTo(FIRST_GRADING_ATTEMPT);
                softly.assertThat(failed.getAccuracyScore()).isZero();
                softly.assertThat(failed.getDeliveryScore()).isZero();
                softly.assertThat(interviewFeedbackRepository.count()).isZero();
            });
        }
    }

    @Nested
    @DisplayName("채점 완료로 전이할 때")
    class CompleteGrading {

        @Test
        void 점수를_반영하고_완료가_된다() {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.GRADING));

            // when
            interviewSessionCommandService.completeGrading(session.getId(), 56, 24);

            // then
            InterviewSession completed = 세션(session.getId());
            assertSoftly(softly -> {
                softly.assertThat(completed.getStatus()).isEqualTo(InterviewSessionStatus.COMPLETED);
                softly.assertThat(completed.getAccuracyScore()).isEqualTo(56);
                softly.assertThat(completed.getDeliveryScore()).isEqualTo(24);
            });
        }

        @Test
        void 만점을_넘으면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.GRADING));
            int overAccuracy = session.getAccuracyMaxScore() + 1;
            int overDelivery = session.getDeliveryMaxScore() + 1;

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.completeGrading(session.getId(), overAccuracy, 0))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_SCORE_INVALID);
            assertThatThrownBy(() -> interviewSessionCommandService.completeGrading(session.getId(), 0, overDelivery))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_SCORE_INVALID);
        }

        @Test
        void 채점_중이_아니면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.TEXT));

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.completeGrading(session.getId(), 0, 0))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_GRADING);
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.completeGrading(UNKNOWN_SESSION_ID, 0, 0))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("채점 실패로 전이할 때")
    class FailGrading {

        @Test
        void 채점_실패가_된다() {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.GRADING));

            // when
            interviewSessionCommandService.failGrading(session.getId());

            // then
            assertThat(세션(session.getId()).getStatus()).isEqualTo(InterviewSessionStatus.GRADING_FAILED);
        }

        @Test
        void 채점_중이_아니면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(상태_세션(USER_ID, InterviewSessionStatus.COMPLETED));

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.failGrading(session.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_GRADING);
        }
    }
}
