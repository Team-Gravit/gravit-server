package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.domain.InterviewTranscriptionStatus;
import gravit.code.interview.dto.response.InterviewTranscriptionResponse;
import gravit.code.interview.dto.response.InterviewTranscriptionsResponse;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_키;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_실패_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_완료_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_중_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewTranscriptionQueryServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long UNKNOWN_SESSION_ID = 999L;
    private static final long QUESTION_ID = 100L;
    private static final long REQUESTED_MINUTES_AGO = 1L;
    private static final int REQUESTED_ANSWER_COUNT = 4;
    private static final String TRANSCRIPT = "트랜잭션 격리 수준은 동시성 제어 방식입니다.";

    @Autowired
    private InterviewTranscriptionQueryService interviewTranscriptionQueryService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private Clock clock;

    private void 상태가_섞인_답안_저장(long sessionId) {
        LocalDateTime requestedAt = LocalDateTime.now(clock).minusMinutes(REQUESTED_MINUTES_AGO);

        // 문항 순서와 다르게 저장해 조회가 문항 순서로 정렬하는지 본다
        interviewAnswerRepository.saveAll(List.<InterviewAnswer>of(
                변환_실패_답안(sessionId, QUESTION_ID + 3, 3, requestedAt),
                변환_완료_답안(sessionId, QUESTION_ID + 1, 1, requestedAt, TRANSCRIPT),
                InterviewAnswer.create(sessionId, QUESTION_ID + 5, 5),
                변환_완료_답안(sessionId, QUESTION_ID + 2, 2, requestedAt, null),
                변환_중_답안(sessionId, QUESTION_ID + 4, 4, requestedAt)
        ));
    }

    @Nested
    @DisplayName("변환 결과를 조회할 때")
    class GetTranscriptions {

        @Test
        void 문항_순서대로_변환_상태와_텍스트를_돌려준다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));
            상태가_섞인_답안_저장(session.getId());

            // when
            InterviewTranscriptionsResponse response = interviewTranscriptionQueryService.getTranscriptions(
                    USER_ID, session.getId());

            // then
            List<InterviewTranscriptionResponse> transcriptions = response.transcriptions();
            assertSoftly(softly -> {
                softly.assertThat(response.sessionId()).isEqualTo(session.getId());
                softly.assertThat(transcriptions)
                        .extracting(InterviewTranscriptionResponse::displayOrder)
                        .containsExactly(1, 2, 3, 4, 5);
                softly.assertThat(transcriptions)
                        .extracting(InterviewTranscriptionResponse::status)
                        .containsExactly(
                                InterviewTranscriptionStatus.COMPLETED,
                                InterviewTranscriptionStatus.COMPLETED,
                                InterviewTranscriptionStatus.FAILED,
                                InterviewTranscriptionStatus.PENDING,
                                null
                        );
                softly.assertThat(transcriptions)
                        .extracting(InterviewTranscriptionResponse::transcript)
                        .containsExactly(TRANSCRIPT, null, null, null, null);
            });
        }

        @Test
        void 변환을_요청한_문항만_답변_음성_재생_URL을_돌려준다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));
            상태가_섞인_답안_저장(session.getId());

            // when
            InterviewTranscriptionsResponse response = interviewTranscriptionQueryService.getTranscriptions(
                    USER_ID, session.getId());

            // then
            List<String> audioUrls = response.transcriptions().stream()
                    .map(InterviewTranscriptionResponse::audioUrl)
                    .toList();
            assertSoftly(softly -> {
                for (int index = 0; index < REQUESTED_ANSWER_COUNT; index++) {
                    softly.assertThat(audioUrls.get(index)).contains(음성_키(session.getId(), index + 1));
                    softly.assertThat(audioUrls.get(index)).contains("X-Amz-Signature=");
                }
                softly.assertThat(audioUrls.get(REQUESTED_ANSWER_COUNT)).isNull();
            });
        }

        @Test
        void 제출한_뒤에도_변환_결과를_돌려준다() {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(USER_ID, InterviewSessionStatus.COMPLETED, InterviewInputType.VOICE));
            상태가_섞인_답안_저장(session.getId());

            // when
            InterviewTranscriptionsResponse response = interviewTranscriptionQueryService.getTranscriptions(
                    USER_ID, session.getId());

            // then
            assertThat(response.transcriptions().get(0).transcript()).isEqualTo(TRANSCRIPT);
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewTranscriptionQueryService.getTranscriptions(USER_ID, UNKNOWN_SESSION_ID))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 남의_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionQueryService.getTranscriptions(OTHER_USER_ID, session.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }

        @Test
        void 텍스트_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.TEXT));

            // when & then
            assertThatThrownBy(() -> interviewTranscriptionQueryService.getTranscriptions(USER_ID, session.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_INPUT_TYPE_MISMATCH);
        }
    }
}
