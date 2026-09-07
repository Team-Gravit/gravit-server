package gravit.code.interview.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewSessionStatus;
import gravit.code.interview.dto.request.InterviewAudioUploadRequest;
import gravit.code.interview.dto.response.InterviewAudioUploadResponse;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.EnumSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.Clock;
import java.time.LocalDateTime;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_AUDIO_FORMAT_UNSUPPORTED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_INPUT_TYPE_MISMATCH;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_ACCESS_DENIED;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_SESSION_NOT_IN_PROGRESS;
import static gravit.code.interview.fixture.InterviewSessionFixture.상태_세션;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewAudioUploadServiceIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long OTHER_USER_ID = 2L;
    private static final long UNKNOWN_SESSION_ID = 999L;
    private static final int DISPLAY_ORDER = 1;
    private static final String M4A = "audio/m4a";
    private static final int UPLOAD_EXPIRY_MINUTES = 10;
    private static final int UPLOAD_EXPIRY_SECONDS = 600;

    @Autowired
    private InterviewAudioUploadService interviewAudioUploadService;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private Clock clock;

    private InterviewAudioUploadRequest 요청(String contentType) {
        return new InterviewAudioUploadRequest(DISPLAY_ORDER, contentType);
    }

    @Nested
    @DisplayName("업로드 URL을 발급할 때")
    class IssueUploadUrl {

        @Test
        void 음성_세션이면_키와_서명된_URL을_돌려준다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when
            InterviewAudioUploadResponse response = interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), 요청(M4A));

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.audioKey())
                        .isEqualTo("interview/" + session.getId() + "/" + DISPLAY_ORDER + ".m4a");
                softly.assertThat(response.uploadUrl()).contains(response.audioKey());
                softly.assertThat(response.uploadUrl()).contains("X-Amz-Signature=");
                softly.assertThat(response.uploadUrl()).contains("X-Amz-Expires=" + UPLOAD_EXPIRY_SECONDS);
                softly.assertThat(response.expiresAt())
                        .isEqualTo(LocalDateTime.now(clock).plusMinutes(UPLOAD_EXPIRY_MINUTES));
            });
        }

        @Test
        void 서명에_콘텐츠_타입이_포함된다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when
            InterviewAudioUploadResponse response = interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), 요청(M4A));

            // then
            assertThat(response.uploadUrl()).contains("content-type");
        }

        @ParameterizedTest
        @CsvSource({
                "audio/m4a, m4a",
                "audio/mp4, m4a",
                "audio/webm, webm",
                "audio/mpeg, mp3"
        })
        void 허용된_포맷마다_확장자가_붙는다(
                String contentType,
                String extension
        ) {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when
            InterviewAudioUploadResponse response = interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), 요청(contentType));

            // then
            assertThat(response.audioKey()).endsWith("." + extension);
        }

        @Test
        void 문항마다_다른_키가_발급된다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when
            InterviewAudioUploadResponse first = interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), new InterviewAudioUploadRequest(1, M4A));
            InterviewAudioUploadResponse second = interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), new InterviewAudioUploadRequest(2, M4A));

            // then
            assertSoftly(softly -> {
                softly.assertThat(first.audioKey()).endsWith("/1.m4a");
                softly.assertThat(second.audioKey()).endsWith("/2.m4a");
                softly.assertThat(first.audioKey()).isNotEqualTo(second.audioKey());
            });
        }

        @Test
        void 텍스트_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.TEXT));

            // when & then
            assertThatThrownBy(() -> interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), 요청(M4A)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_INPUT_TYPE_MISMATCH);
        }

        @ParameterizedTest
        @EnumSource(value = InterviewSessionStatus.class, names = {"GRADING", "COMPLETED", "GRADING_FAILED", "ABANDONED"})
        void 진행_중이_아니면_예외를_던진다(InterviewSessionStatus status) {
            // given
            InterviewSession session = interviewSessionRepository.save(
                    상태_세션(USER_ID, status, InterviewInputType.VOICE));

            // when & then
            assertThatThrownBy(() -> interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), 요청(M4A)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_IN_PROGRESS);
        }

        @Test
        void 없는_세션이면_예외를_던진다() {
            // when & then
            assertThatThrownBy(() -> interviewAudioUploadService.issueUploadUrl(
                    USER_ID, UNKNOWN_SESSION_ID, 요청(M4A)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_NOT_FOUND);
        }

        @Test
        void 남의_세션이면_예외를_던진다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when & then
            assertThatThrownBy(() -> interviewAudioUploadService.issueUploadUrl(
                    OTHER_USER_ID, session.getId(), 요청(M4A)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_SESSION_ACCESS_DENIED);
        }

        @ParameterizedTest
        @ValueSource(strings = {"audio/flac", "video/mp4", "application/octet-stream", "m4a"})
        void 허용하지_않는_포맷이면_예외를_던진다(String contentType) {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));

            // when & then
            assertThatThrownBy(() -> interviewAudioUploadService.issueUploadUrl(
                    USER_ID, session.getId(), 요청(contentType)))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INTERVIEW_AUDIO_FORMAT_UNSUPPORTED);
        }
    }
}
