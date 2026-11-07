package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewAnswerStatus;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.domain.InterviewTranscriptionStatus;
import gravit.code.interview.dto.request.InterviewTranscriptionRequest;
import gravit.code.interview.facade.InterviewTranscriptionFacade;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.transaction.support.TransactionTemplate;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_ALREADY_SUBMITTED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_ANSWER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_EMPTY;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_KEY_INVALID;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_NOT_UPLOADED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ABANDONED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ALREADY_SUBMITTED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TRANSCRIPTION_ALREADY_REQUESTED;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.권한_거부;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.본문_없는_404;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.빈_음성;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_없음;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_있음;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_키;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_실패_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_완료_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_중_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@TCSpringBootTest
class InterviewTranscriptionCommandServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long UNKNOWN_SESSION_ID = 999L;
    private static final long UNKNOWN_ANSWER_ID = 999L;
    private static final long QUESTION_ID = 100L;
    private static final int DISPLAY_ORDER = 1;
    private static final int OTHER_DISPLAY_ORDER = 2;
    private static final int LAST_DISPLAY_ORDER = 3;
    private static final long ASYNC_TIMEOUT_MILLIS = 5_000L;
    private static final long IN_PROGRESS_ELAPSED_MINUTES = 1L;
    private static final int FORBIDDEN_STATUS = 403;
    private static final String TRANSCRIPT = "트랜잭션 격리 수준은 동시성 제어 방식입니다.";
    private static final String PREVIOUS_TRANSCRIPT = "먼저 끝난 변환 결과";
    private static final String SUBMITTED_CONTENT = "사용자가 고쳐 제출한 답변";
    private static final long LOCK_WAIT_MILLIS = 500L;
    private static final long TIMEOUT_SECONDS = 10L;

    @Autowired
    private InterviewTranscriptionCommandService interviewTranscriptionCommandService;

    @Autowired
    private InterviewSessionCommandService interviewSessionCommandService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private TransactionTemplate transactionTemplate;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private Clock clock;

    @MockitoBean
    private S3Client s3Client;

    @MockitoSpyBean
    private InterviewTranscriptionFacade interviewTranscriptionFacade;

    @BeforeEach
    void setUp() {
        // 커밋 후 비동기 변환이 실제로 돌면 답안 상태를 바꿔 검증이 타이밍에 따라 깨진다
        doNothing().when(interviewTranscriptionFacade).transcribe(anyLong(), anyString());
        when(s3Client.headObject(any(HeadObjectRequest.class))).thenReturn(음성_있음());
    }

    private InterviewSession 음성_세션() {
        return interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));
    }

    private InterviewAnswer 미요청_답안_저장(
            long sessionId,
            int displayOrder
    ) {
        return interviewAnswerRepository.save(InterviewAnswer.create(sessionId, QUESTION_ID + displayOrder, displayOrder));
    }

    private InterviewAnswer 답안(long answerId) {
        return interviewAnswerRepository.findById(answerId).orElseThrow();
    }

    private InterviewTranscriptionRequest 요청(long sessionId) {
        return new InterviewTranscriptionRequest(DISPLAY_ORDER, 음성_키(sessionId, DISPLAY_ORDER));
    }

    private LocalDateTime 지금() {
        return LocalDateTime.now(clock);
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

    private void 음성과_변환_결과가_비어_있다(long answerId) {
        InterviewAnswer discarded = 답안(answerId);
        assertSoftly(softly -> {
            softly.assertThat(discarded.getAudioKey()).isNull();
            softly.assertThat(discarded.getTranscript()).isNull();
            softly.assertThat(discarded.getTranscriptionStatus()).isNull();
            softly.assertThat(discarded.getTranscriptionRequestedAt()).isNull();
        });
    }

    @Nested
    @DisplayName("변환을 요청할 때")
    class Request {

        @Test
        void 답안을_변환_중으로_바꾸고_음성_키를_기록한_뒤_커밋_후_변환을_시작한다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = 미요청_답안_저장(session.getId(), DISPLAY_ORDER);

            // when
            interviewTranscriptionCommandService.request(USER_ID, session.getId(), 요청(session.getId()));

            // then
            InterviewAnswer requested = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(requested.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.PENDING);
                softly.assertThat(requested.getTranscriptionRequestedAt()).isEqualTo(지금());
                softly.assertThat(requested.getTranscript()).isNull();
                softly.assertThat(requested.getAudioKey()).isEqualTo(음성_키(session.getId(), DISPLAY_ORDER));
            });
            verify(interviewTranscriptionFacade, timeout(ASYNC_TIMEOUT_MILLIS))
                    .transcribe(answer.getId(), 음성_키(session.getId(), DISPLAY_ORDER));
        }

        @Test
        void 요청한_문항의_답안만_바꾼다() {
            // given
            InterviewSession session = 음성_세션();
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            InterviewAnswer other = 미요청_답안_저장(session.getId(), OTHER_DISPLAY_ORDER);

            // when
            interviewTranscriptionCommandService.request(USER_ID, session.getId(), 요청(session.getId()));

            // then
            assertThat(답안(other.getId()).getTranscriptionStatus()).isNull();
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, UNKNOWN_SESSION_ID, 요청(UNKNOWN_SESSION_ID)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 남의_세션이면_저장소를_조회하지_않고_예외를_던진다() {
            // given
            InterviewSession session = 음성_세션();
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    OTHER_USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
            verify(s3Client, never()).headObject(any(HeadObjectRequest.class));
        }

        @Test
        void 텍스트_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.TEXT));
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_INPUT_TYPE_MISMATCH);
        }

        @Test
        void 취소된_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(USER_ID, InterviewSessionStatus.ABANDONED, InterviewInputType.VOICE));
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ABANDONED);
        }

        @ParameterizedTest
        @EnumSource(value = InterviewSessionStatus.class, names = {"GRADING", "COMPLETED", "GRADING_FAILED"})
        void 제출_이후_세션이면_예외를_던진다(InterviewSessionStatus status) {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(USER_ID, status, InterviewInputType.VOICE));
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ALREADY_SUBMITTED);
        }

        @ParameterizedTest
        @ValueSource(strings = {
                "not-a-server-issued-key",
                "interview/%d/2.m4a",
                "interview/%d/1.wav",
                "interview/0/1.m4a"
        })
        void 발급한_형식이_아니거나_다른_문항의_음성_키면_예외를_던진다(String keyFormat) {
            // given
            InterviewSession session = 음성_세션();
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            InterviewTranscriptionRequest request = new InterviewTranscriptionRequest(
                    DISPLAY_ORDER, keyFormat.formatted(session.getId()));

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(USER_ID, session.getId(), request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_KEY_INVALID);
        }

        @Test
        void 업로드된_음성이_없으면_예외를_던지고_답안은_그대로다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = 미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            when(s3Client.headObject(any(HeadObjectRequest.class))).thenThrow(음성_없음());

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_NOT_UPLOADED);
            assertThat(답안(answer.getId()).getTranscriptionStatus()).isNull();
        }

        @Test
        void 업로드된_음성이_비어_있으면_예외를_던지고_답안은_그대로다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = 미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            when(s3Client.headObject(any(HeadObjectRequest.class))).thenReturn(빈_음성());

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_EMPTY);
            assertThat(답안(answer.getId()).getTranscriptionStatus()).isNull();
        }

        @Test
        void 본문_없는_404로_응답해도_업로드되지_않은_것으로_본다() {
            // given
            InterviewSession session = 음성_세션();
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            when(s3Client.headObject(any(HeadObjectRequest.class))).thenThrow(본문_없는_404());

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_NOT_UPLOADED);
        }

        @Test
        void 저장소_권한_오류는_없음으로_바꾸지_않고_그대로_던진다() {
            // given
            InterviewSession session = 음성_세션();
            미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            when(s3Client.headObject(any(HeadObjectRequest.class))).thenThrow(권한_거부());

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(S3Exception.class)
                    .extracting(e -> ((S3Exception) e).statusCode())
                    .isEqualTo(FORBIDDEN_STATUS);
        }

        @Test
        void 문항의_답안이_없으면_예외를_던진다() {
            // given
            InterviewSession session = 음성_세션();

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_NOT_FOUND);
        }

        @Test
        void 이미_제출된_답안이면_예외를_던진다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = InterviewAnswer.create(session.getId(), QUESTION_ID + DISPLAY_ORDER, DISPLAY_ORDER);
            ReflectionTestUtils.setField(answer, "status", InterviewAnswerStatus.ANSWERED);
            interviewAnswerRepository.save(answer);

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_ALREADY_SUBMITTED);
        }

        @Test
        void 변환이_완료된_답안이면_예외를_던지고_결과는_그대로다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = interviewAnswerRepository.save(변환_완료_답안(
                    session.getId(), QUESTION_ID + DISPLAY_ORDER, DISPLAY_ORDER, 지금().minusMinutes(IN_PROGRESS_ELAPSED_MINUTES), TRANSCRIPT));

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TRANSCRIPTION_ALREADY_REQUESTED);

            InterviewAnswer unchanged = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(unchanged.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.COMPLETED);
                softly.assertThat(unchanged.getTranscript()).isEqualTo(TRANSCRIPT);
            });
        }

        @ParameterizedTest
        @ValueSource(longs = {0L, 1L, 4L})
        void 요청_후_5분이_지나지_않은_변환_중_답안이면_예외를_던진다(long elapsedMinutes) {
            // given
            InterviewSession session = 음성_세션();
            interviewAnswerRepository.save(변환_중_답안(
                    session.getId(), QUESTION_ID + DISPLAY_ORDER, DISPLAY_ORDER, 지금().minusMinutes(elapsedMinutes)));

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.request(
                    USER_ID, session.getId(), 요청(session.getId())))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TRANSCRIPTION_ALREADY_REQUESTED);
        }

        @Test
        void 변환에_실패한_답안이면_다시_변환_중으로_바꾼다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = interviewAnswerRepository.save(변환_실패_답안(
                    session.getId(), QUESTION_ID + DISPLAY_ORDER, DISPLAY_ORDER, 지금().minusMinutes(IN_PROGRESS_ELAPSED_MINUTES)));

            // when
            interviewTranscriptionCommandService.request(USER_ID, session.getId(), 요청(session.getId()));

            // then
            InterviewAnswer requested = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(requested.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.PENDING);
                softly.assertThat(requested.getTranscriptionRequestedAt()).isEqualTo(지금());
            });
            verify(interviewTranscriptionFacade, timeout(ASYNC_TIMEOUT_MILLIS))
                    .transcribe(answer.getId(), 음성_키(session.getId(), DISPLAY_ORDER));
        }

        @ParameterizedTest
        @ValueSource(longs = {5L, 6L})
        void 요청_후_5분이_지난_변환_중_답안이면_요청_시각을_새로_기록한다(long elapsedMinutes) {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = interviewAnswerRepository.save(변환_중_답안(
                    session.getId(), QUESTION_ID + DISPLAY_ORDER, DISPLAY_ORDER, 지금().minusMinutes(elapsedMinutes)));

            // when
            interviewTranscriptionCommandService.request(USER_ID, session.getId(), 요청(session.getId()));

            // then
            InterviewAnswer requested = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(requested.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.PENDING);
                softly.assertThat(requested.getTranscriptionRequestedAt()).isEqualTo(지금());
            });
            verify(interviewTranscriptionFacade, timeout(ASYNC_TIMEOUT_MILLIS))
                    .transcribe(answer.getId(), 음성_키(session.getId(), DISPLAY_ORDER));
        }
    }

    @Nested
    @DisplayName("변환을 완료할 때")
    class Complete {

        private InterviewAnswer 변환_중_답안_저장() {
            InterviewSession session = 음성_세션();
            return interviewAnswerRepository.save(변환_중_답안(
                    session.getId(), QUESTION_ID + DISPLAY_ORDER, DISPLAY_ORDER, 지금().minusMinutes(IN_PROGRESS_ELAPSED_MINUTES)));
        }

        @Test
        void 앞뒤_공백을_제거한_텍스트를_저장하고_완료로_바꾼다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장();

            // when
            interviewTranscriptionCommandService.complete(answer.getId(), "  " + TRANSCRIPT + "\n");

            // then
            InterviewAnswer completed = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(completed.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.COMPLETED);
                softly.assertThat(completed.getTranscript()).isEqualTo(TRANSCRIPT);
            });
        }

        @ParameterizedTest
        @NullAndEmptySource
        @ValueSource(strings = {"   ", "\n\t"})
        void 변환된_말이_없으면_텍스트를_비우고_완료로_바꾼다(String transcript) {
            // given
            InterviewAnswer answer = 변환_중_답안_저장();

            // when
            interviewTranscriptionCommandService.complete(answer.getId(), transcript);

            // then
            InterviewAnswer completed = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(completed.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.COMPLETED);
                softly.assertThat(completed.getTranscript()).isNull();
            });
        }

        @Test
        void 변환_중이_아닌_답안은_그대로_둔다() {
            // given
            InterviewSession session = 음성_세션();
            LocalDateTime requestedAt = 지금().minusMinutes(IN_PROGRESS_ELAPSED_MINUTES);
            InterviewAnswer notRequested = 미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            InterviewAnswer completed = interviewAnswerRepository.save(변환_완료_답안(
                    session.getId(), QUESTION_ID + OTHER_DISPLAY_ORDER, OTHER_DISPLAY_ORDER, requestedAt, PREVIOUS_TRANSCRIPT));
            InterviewAnswer failed = interviewAnswerRepository.save(변환_실패_답안(
                    session.getId(), QUESTION_ID + LAST_DISPLAY_ORDER, LAST_DISPLAY_ORDER, requestedAt));

            // when
            interviewTranscriptionCommandService.complete(notRequested.getId(), TRANSCRIPT);
            interviewTranscriptionCommandService.complete(completed.getId(), TRANSCRIPT);
            interviewTranscriptionCommandService.complete(failed.getId(), TRANSCRIPT);

            // then
            assertSoftly(softly -> {
                softly.assertThat(답안(notRequested.getId()).getTranscriptionStatus()).isNull();
                softly.assertThat(답안(notRequested.getId()).getTranscript()).isNull();
                softly.assertThat(답안(completed.getId()).getTranscript()).isEqualTo(PREVIOUS_TRANSCRIPT);
                softly.assertThat(답안(failed.getId()).getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.FAILED);
                softly.assertThat(답안(failed.getId()).getTranscript()).isNull();
            });
        }

        @Test
        void 읽은_뒤에_바뀐_제출_컬럼을_덮어쓰지_않는다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장();
            String audioKey = 음성_키(answer.getSessionId(), DISPLAY_ORDER);

            // when - 제출 전 상태로 읽어 둔 뒤 제출 컬럼이 바뀌고, 그 다음 변환 결과가 반영된다
            transactionTemplate.executeWithoutResult(status -> {
                interviewAnswerRepository.findById(answer.getId()).orElseThrow();
                jdbcTemplate.update(
                        "UPDATE interview_answer SET status = ?, content = ?, audio_key = ? WHERE id = ?",
                        InterviewAnswerStatus.ANSWERED.name(), SUBMITTED_CONTENT, audioKey, answer.getId()
                );
                interviewTranscriptionCommandService.complete(answer.getId(), TRANSCRIPT);
            });

            // then
            InterviewAnswer result = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(result.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.COMPLETED);
                softly.assertThat(result.getTranscript()).isEqualTo(TRANSCRIPT);
                softly.assertThat(result.getStatus()).isEqualTo(InterviewAnswerStatus.ANSWERED);
                softly.assertThat(result.getContent()).isEqualTo(SUBMITTED_CONTENT);
                softly.assertThat(result.getAudioKey()).isEqualTo(audioKey);
            });
        }

        @Test
        void 없는_답안이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.complete(UNKNOWN_ANSWER_ID, TRANSCRIPT))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("변환을 실패로 바꿀 때")
    class Fail {

        @Test
        void 변환_중인_답안을_실패로_바꾼다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = interviewAnswerRepository.save(변환_중_답안(
                    session.getId(), QUESTION_ID + DISPLAY_ORDER, DISPLAY_ORDER, 지금().minusMinutes(IN_PROGRESS_ELAPSED_MINUTES)));

            // when
            interviewTranscriptionCommandService.fail(answer.getId());

            // then
            InterviewAnswer failed = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(failed.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.FAILED);
                softly.assertThat(failed.getTranscript()).isNull();
            });
        }

        @Test
        void 변환_중이_아닌_답안은_그대로_둔다() {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer notRequested = 미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            InterviewAnswer completed = interviewAnswerRepository.save(변환_완료_답안(
                    session.getId(), QUESTION_ID + OTHER_DISPLAY_ORDER, OTHER_DISPLAY_ORDER,
                    지금().minusMinutes(IN_PROGRESS_ELAPSED_MINUTES), PREVIOUS_TRANSCRIPT));

            // when
            interviewTranscriptionCommandService.fail(notRequested.getId());
            interviewTranscriptionCommandService.fail(completed.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(답안(notRequested.getId()).getTranscriptionStatus()).isNull();
                softly.assertThat(답안(completed.getId()).getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.COMPLETED);
                softly.assertThat(답안(completed.getId()).getTranscript()).isEqualTo(PREVIOUS_TRANSCRIPT);
            });
        }

        @Test
        void 없는_답안이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewTranscriptionCommandService.fail(UNKNOWN_ANSWER_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_ANSWER_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("취소와 변환 요청이 겹칠 때")
    class AbandonRequestRace {

        @Test
        void 취소가_먼저_잠그면_변환_요청이_중단된_세션_예외로_거부된다() throws Exception {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = 미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            CountDownLatch abandonLocked = new CountDownLatch(1);
            CountDownLatch abandonReleased = new CountDownLatch(1);
            ExecutorService executor = Executors.newFixedThreadPool(2);

            try {
                Future<?> abandon = executor.submit(() -> transactionTemplate.executeWithoutResult(status -> {
                    interviewSessionCommandService.abandon(USER_ID, session.getId());
                    abandonLocked.countDown();
                    대기(abandonReleased);
                }));
                대기(abandonLocked);

                // when
                Future<?> request = executor.submit(() ->
                        interviewTranscriptionCommandService.request(USER_ID, session.getId(), 요청(session.getId())));
                boolean waitedForAbandon = 끝나지_않고_대기_중인지(request);

                abandonReleased.countDown();
                abandon.get(TIMEOUT_SECONDS, TimeUnit.SECONDS);

                // then
                assertThat(waitedForAbandon).isTrue();
                assertThatThrownBy(() -> request.get(TIMEOUT_SECONDS, TimeUnit.SECONDS))
                        .hasCauseInstanceOf(RestApiException.class)
                        .extracting(e -> ((RestApiException) e.getCause()).getErrorCode())
                        .isEqualTo(INTERVIEW_SESSION_ABANDONED);
                음성과_변환_결과가_비어_있다(answer.getId());
                verify(interviewTranscriptionFacade, never()).transcribe(anyLong(), anyString());
            } finally {
                abandonReleased.countDown();
                executor.shutdownNow();
            }
        }

        @Test
        void 변환_요청이_먼저_잠그면_취소가_요청한_답안의_음성까지_비운다() throws Exception {
            // given
            InterviewSession session = 음성_세션();
            InterviewAnswer answer = 미요청_답안_저장(session.getId(), DISPLAY_ORDER);
            CountDownLatch requestLocked = new CountDownLatch(1);
            CountDownLatch requestReleased = new CountDownLatch(1);
            ExecutorService executor = Executors.newFixedThreadPool(2);

            try {
                Future<?> request = executor.submit(() -> transactionTemplate.executeWithoutResult(status -> {
                    interviewTranscriptionCommandService.request(USER_ID, session.getId(), 요청(session.getId()));
                    requestLocked.countDown();
                    대기(requestReleased);
                }));
                대기(requestLocked);

                // when
                Future<?> abandon = executor.submit(() -> interviewSessionCommandService.abandon(USER_ID, session.getId()));
                boolean waitedForRequest = 끝나지_않고_대기_중인지(abandon);

                requestReleased.countDown();
                request.get(TIMEOUT_SECONDS, TimeUnit.SECONDS);
                abandon.get(TIMEOUT_SECONDS, TimeUnit.SECONDS);

                // then
                assertSoftly(softly -> {
                    softly.assertThat(waitedForRequest).isTrue();
                    softly.assertThat(interviewSessionRepository.findById(session.getId()).orElseThrow().getStatus())
                            .isEqualTo(InterviewSessionStatus.ABANDONED);
                });
                음성과_변환_결과가_비어_있다(answer.getId());
            } finally {
                requestReleased.countDown();
                executor.shutdownNow();
            }
        }
    }
}
