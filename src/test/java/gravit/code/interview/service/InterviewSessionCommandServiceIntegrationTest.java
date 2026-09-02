package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewLevel;
import gravit.code.interview.domain.InterviewMode;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.request.InterviewSessionCreateRequest;
import gravit.code.interview.dto.response.InterviewSessionStatusResponse;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_NOT_SUPPORTED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ALREADY_IN_PROGRESS;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TECH_STACK_NOT_ALLOWED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TECH_STACK_REQUIRED;
import static gravit.code.interview.fixture.InterviewSessionFixture.공통CS_생성요청;
import static gravit.code.interview.fixture.InterviewSessionFixture.공통CS_진행중_세션;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewSessionCommandServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long TECH_STACK_ID = 1L;
    private static final long NOT_EXIST_SESSION_ID = 999L;
    private static final int EXPECTED_ACCURACY_MAX_SCORE = 70;
    private static final int EXPECTED_COHERENCE_MAX_SCORE = 30;

    @Autowired
    private InterviewSessionCommandService interviewSessionCommandService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Nested
    @DisplayName("세션을 만들 수 있는지 검증할 때")
    class ValidateCreatable {

        @Test
        void 조건을_모두_만족하면_통과한다() {
            // when & then
            assertThatCode(() -> interviewSessionCommandService.validateCreatable(USER_ID, 공통CS_생성요청()))
                    .doesNotThrowAnyException();
        }

        @Test
        void 음성_입력을_요청하면_예외를_던진다() {
            // given
            InterviewSessionCreateRequest request = new InterviewSessionCreateRequest(
                    InterviewMode.COMMON_CS,
                    InterviewInputType.VOICE,
                    InterviewLevel.MEDIUM,
                    null
            );

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateCreatable(USER_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_INPUT_TYPE_NOT_SUPPORTED);
        }

        @Test
        void 직무별인데_기술_스택이_없으면_예외를_던진다() {
            // given
            InterviewSessionCreateRequest request = new InterviewSessionCreateRequest(
                    InterviewMode.JOB_SPECIFIC,
                    InterviewInputType.TEXT,
                    InterviewLevel.MEDIUM,
                    null
            );

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateCreatable(USER_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TECH_STACK_REQUIRED);
        }

        @Test
        void 공통CS인데_기술_스택을_지정하면_예외를_던진다() {
            // given
            InterviewSessionCreateRequest request = new InterviewSessionCreateRequest(
                    InterviewMode.COMMON_CS,
                    InterviewInputType.TEXT,
                    InterviewLevel.MEDIUM,
                    TECH_STACK_ID
            );

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateCreatable(USER_ID, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_TECH_STACK_NOT_ALLOWED);
        }

        @Test
        void 진행_중인_세션이_있으면_예외를_던진다() {
            // given
            interviewSessionRepository.save(공통CS_진행중_세션(USER_ID));

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateCreatable(USER_ID, 공통CS_생성요청()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ALREADY_IN_PROGRESS);
        }

        @Test
        void 다른_사용자의_진행_중인_세션은_막지_않는다() {
            // given
            interviewSessionRepository.save(공통CS_진행중_세션(OTHER_USER_ID));

            // when & then
            assertThatCode(() -> interviewSessionCommandService.validateCreatable(USER_ID, 공통CS_생성요청()))
                    .doesNotThrowAnyException();
        }

        @Test
        void 채점_중인_세션은_막지_않는다() {
            // given
            InterviewSession session = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID));
            interviewSessionCommandService.startGrading(USER_ID, session.getId());

            // when & then
            assertThatCode(() -> interviewSessionCommandService.validateCreatable(USER_ID, 공통CS_생성요청()))
                    .doesNotThrowAnyException();
        }
    }

    @Nested
    @DisplayName("세션을 만들 때")
    class CreateSession {

        @Test
        void 진행_중_상태와_만점을_함께_저장한다() {
            // when
            long sessionId = interviewSessionCommandService.createSession(USER_ID, 공통CS_생성요청());

            // then
            InterviewSession saved = interviewSessionRepository.findById(sessionId).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(saved.getStatus()).isEqualTo(InterviewSessionStatus.IN_PROGRESS);
                softly.assertThat(saved.getAccuracyMaxScore()).isEqualTo(EXPECTED_ACCURACY_MAX_SCORE);
                softly.assertThat(saved.getCoherenceMaxScore()).isEqualTo(EXPECTED_COHERENCE_MAX_SCORE);
                softly.assertThat(saved.getStartedAt()).isNotNull();
                softly.assertThat(saved.getEndedAt()).isNull();
            });
        }
    }

    @Nested
    @DisplayName("답변할 수 있는지 검증할 때")
    class ValidateAnswerable {

        @Test
        void 진행_중인_본인_세션이면_통과한다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID)).getId();

            // when & then
            assertThatCode(() -> interviewSessionCommandService.validateAnswerable(
                    USER_ID,
                    sessionId,
                    InterviewInputType.TEXT
            )).doesNotThrowAnyException();
        }

        @Test
        void 존재하지_않는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateAnswerable(
                    USER_ID,
                    NOT_EXIST_SESSION_ID,
                    InterviewInputType.TEXT
            ))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 남의_세션이면_예외를_던진다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(OTHER_USER_ID)).getId();

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateAnswerable(
                    USER_ID,
                    sessionId,
                    InterviewInputType.TEXT
            ))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }

        @Test
        void 진행_중인_세션이_아니면_예외를_던진다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID)).getId();
            interviewSessionCommandService.abandon(USER_ID, sessionId);

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateAnswerable(
                    USER_ID,
                    sessionId,
                    InterviewInputType.TEXT
            ))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        @Test
        void 세션의_입력_방식과_다르면_예외를_던진다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID)).getId();

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.validateAnswerable(
                    USER_ID,
                    sessionId,
                    InterviewInputType.VOICE
            ))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_INPUT_TYPE_MISMATCH);
        }
    }

    @Nested
    @DisplayName("세션을 끝낼 때")
    class StartGrading {

        @Test
        void 채점_중_상태로_바꾼다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID)).getId();

            // when
            InterviewSessionStatusResponse response = interviewSessionCommandService.startGrading(USER_ID, sessionId);

            // then
            InterviewSession saved = interviewSessionRepository.findById(sessionId).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(response.status()).isEqualTo(InterviewSessionStatus.GRADING);
                softly.assertThat(saved.getStatus()).isEqualTo(InterviewSessionStatus.GRADING);
                softly.assertThat(saved.getEndedAt()).isNull();
            });
        }

        @Test
        void 이미_끝난_세션이면_예외를_던진다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID)).getId();
            interviewSessionCommandService.startGrading(USER_ID, sessionId);

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.startGrading(USER_ID, sessionId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        @Test
        void 남의_세션이면_예외를_던진다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(OTHER_USER_ID)).getId();

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.startGrading(USER_ID, sessionId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }
    }

    @Nested
    @DisplayName("세션을 중단할 때")
    class Abandon {

        @Test
        void 중단_상태로_바꾸고_종료_시각을_남긴다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID)).getId();

            // when
            InterviewSessionStatusResponse response = interviewSessionCommandService.abandon(USER_ID, sessionId);

            // then
            InterviewSession saved = interviewSessionRepository.findById(sessionId).orElseThrow();

            assertSoftly(softly -> {
                softly.assertThat(response.status()).isEqualTo(InterviewSessionStatus.ABANDONED);
                softly.assertThat(saved.getStatus()).isEqualTo(InterviewSessionStatus.ABANDONED);
                softly.assertThat(saved.getEndedAt()).isNotNull();
            });
        }

        @Test
        void 채점_중인_세션은_중단할_수_없다() {
            // given
            long sessionId = interviewSessionRepository.save(공통CS_진행중_세션(USER_ID)).getId();
            interviewSessionCommandService.startGrading(USER_ID, sessionId);

            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.abandon(USER_ID, sessionId))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        @Test
        void 존재하지_않는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewSessionCommandService.abandon(USER_ID, NOT_EXIST_SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }
    }
}
