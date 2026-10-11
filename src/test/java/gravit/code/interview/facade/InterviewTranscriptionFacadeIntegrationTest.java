package gravit.code.interview.facade;

import gravit.code.interview.domain.InterviewAnswer;
import gravit.code.interview.domain.InterviewAnswerStatus;
import gravit.code.interview.domain.InterviewInputType;
import gravit.code.interview.domain.InterviewSession;
import gravit.code.interview.domain.InterviewTranscriptionStatus;
import gravit.code.interview.repository.InterviewAnswerRepository;
import gravit.code.interview.repository.InterviewSessionRepository;
import gravit.code.interviewQuestion.domain.InterviewConceptType;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.repository.InterviewQuestionConceptRepository;
import gravit.code.interviewQuestion.repository.InterviewQuestionRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.ai.audio.transcription.AudioTranscription;
import org.springframework.ai.audio.transcription.AudioTranscriptionPrompt;
import org.springframework.ai.audio.transcription.AudioTranscriptionResponse;
import org.springframework.ai.openai.OpenAiAudioTranscriptionModel;
import org.springframework.ai.openai.OpenAiAudioTranscriptionOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.util.ReflectionTestUtils;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

import java.time.Clock;
import java.time.LocalDateTime;

import static gravit.code.interview.fixture.InterviewAudioS3Fixture.권한_거부;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_내용;
import static gravit.code.interview.fixture.InterviewAudioS3Fixture.음성_키;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_완료_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.변환_중_답안;
import static gravit.code.interview.fixture.InterviewSessionFixture.진행중_세션;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.개념;
import static gravit.code.interviewFeedback.fixture.InterviewFeedbackFixture.문제;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@TCSpringBootTest
class InterviewTranscriptionFacadeIntegrationTest {

    private static final long USER_ID = 1L;
    private static final long UNIT_ID = 11L;
    private static final long UNKNOWN_ANSWER_ID = 999L;
    private static final long QUESTION_ID_WITHOUT_CONCEPT = 100L;
    private static final int DISPLAY_ORDER = 1;
    private static final long REQUESTED_MINUTES_AGO = 1L;
    private static final byte[] AUDIO = {1, 2, 3, 4};
    private static final String AUDIO_FILE_NAME = DISPLAY_ORDER + ".m4a";
    private static final String ESSENTIAL_CONCEPT = "트랜잭션 격리 수준";
    private static final String SUPPLEMENTARY_CONCEPT = "MVCC";
    private static final String TRANSCRIPT = "트랜잭션 격리 수준은 동시성 제어 방식입니다.";
    private static final String PREVIOUS_TRANSCRIPT = "먼저 끝난 변환 결과";
    private static final String SUBMITTED_CONTENT = "사용자가 고쳐 제출한 답변";
    private static final String MODEL_ERROR_MESSAGE = "LiteLLM 호출 실패";

    @Autowired
    private InterviewTranscriptionFacade interviewTranscriptionFacade;

    @Autowired
    private InterviewSessionRepository interviewSessionRepository;

    @Autowired
    private InterviewAnswerRepository interviewAnswerRepository;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Autowired
    private InterviewQuestionConceptRepository interviewQuestionConceptRepository;

    @Autowired
    private Clock clock;

    @MockitoBean
    private S3Client s3Client;

    @MockitoBean
    private OpenAiAudioTranscriptionModel transcriptionModel;

    @BeforeEach
    void setUp() {
        when(s3Client.getObjectAsBytes(any(GetObjectRequest.class))).thenReturn(음성_내용(AUDIO));
        when(transcriptionModel.call(any(AudioTranscriptionPrompt.class))).thenReturn(변환_응답("  " + TRANSCRIPT + "\n"));
    }

    private AudioTranscriptionResponse 변환_응답(String transcript) {
        return new AudioTranscriptionResponse(new AudioTranscription(transcript));
    }

    private long 개념이_있는_문제() {
        InterviewQuestion question = interviewQuestionRepository.save(문제(InterviewTopic.DATABASE, UNIT_ID));
        interviewQuestionConceptRepository.save(개념(question.getId(), ESSENTIAL_CONCEPT, InterviewConceptType.ESSENTIAL, 1));
        interviewQuestionConceptRepository.save(개념(question.getId(), SUPPLEMENTARY_CONCEPT, InterviewConceptType.SUPPLEMENTARY, 2));
        return question.getId();
    }

    private InterviewAnswer 변환_중_답안_저장(long questionId) {
        InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));
        LocalDateTime requestedAt = LocalDateTime.now(clock).minusMinutes(REQUESTED_MINUTES_AGO);
        return interviewAnswerRepository.save(변환_중_답안(session.getId(), questionId, DISPLAY_ORDER, requestedAt));
    }

    private String 키(InterviewAnswer answer) {
        return 음성_키(answer.getSessionId(), answer.getDisplayOrder());
    }

    private InterviewAnswer 답안(long answerId) {
        return interviewAnswerRepository.findById(answerId).orElseThrow();
    }

    private AudioTranscriptionPrompt 변환_호출_인자() {
        ArgumentCaptor<AudioTranscriptionPrompt> captor = ArgumentCaptor.forClass(AudioTranscriptionPrompt.class);
        verify(transcriptionModel).call(captor.capture());
        return captor.getValue();
    }

    @Nested
    @DisplayName("음성을 변환할 때")
    class Transcribe {

        @Test
        void 저장소의_음성을_변환해_앞뒤_공백을_제거한_텍스트를_저장하고_완료로_바꾼다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장(개념이_있는_문제());

            // when
            interviewTranscriptionFacade.transcribe(answer.getId(), 키(answer));

            // then
            ArgumentCaptor<GetObjectRequest> downloadCaptor = ArgumentCaptor.forClass(GetObjectRequest.class);
            verify(s3Client).getObjectAsBytes(downloadCaptor.capture());

            InterviewAnswer completed = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(downloadCaptor.getValue().key()).isEqualTo(키(answer));
                softly.assertThat(completed.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.COMPLETED);
                softly.assertThat(completed.getTranscript()).isEqualTo(TRANSCRIPT);
            });
        }

        @Test
        void 문항의_핵심_개념을_변환_힌트로_넘기고_음성에_키의_파일명을_붙인다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장(개념이_있는_문제());

            // when
            interviewTranscriptionFacade.transcribe(answer.getId(), 키(answer));

            // then
            AudioTranscriptionPrompt prompt = 변환_호출_인자();
            assertSoftly(softly -> {
                softly.assertThat(prompt.getOptions()).isInstanceOf(OpenAiAudioTranscriptionOptions.class);
                softly.assertThat(((OpenAiAudioTranscriptionOptions) prompt.getOptions()).getPrompt())
                        .contains(ESSENTIAL_CONCEPT, SUPPLEMENTARY_CONCEPT);
                softly.assertThat(prompt.getInstructions().getFilename()).isEqualTo(AUDIO_FILE_NAME);
                softly.assertThat(((ByteArrayResource) prompt.getInstructions()).getByteArray()).isEqualTo(AUDIO);
            });
        }

        @Test
        void 핵심_개념이_없는_문항이면_변환_힌트_없이_호출한다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장(QUESTION_ID_WITHOUT_CONCEPT);

            // when
            interviewTranscriptionFacade.transcribe(answer.getId(), 키(answer));

            // then
            AudioTranscriptionPrompt prompt = 변환_호출_인자();
            assertSoftly(softly -> {
                softly.assertThat(prompt.getOptions()).isNull();
                softly.assertThat(답안(answer.getId()).getTranscriptionStatus())
                        .isEqualTo(InterviewTranscriptionStatus.COMPLETED);
            });
        }

        @Test
        void 변환_호출이_실패하면_실패로_바꾼다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장(개념이_있는_문제());
            when(transcriptionModel.call(any(AudioTranscriptionPrompt.class)))
                    .thenThrow(new IllegalStateException(MODEL_ERROR_MESSAGE));

            // when
            interviewTranscriptionFacade.transcribe(answer.getId(), 키(answer));

            // then
            InterviewAnswer failed = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(failed.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.FAILED);
                softly.assertThat(failed.getTranscript()).isNull();
            });
        }

        @Test
        void 음성_다운로드가_실패하면_변환을_호출하지_않고_실패로_바꾼다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장(개념이_있는_문제());
            when(s3Client.getObjectAsBytes(any(GetObjectRequest.class))).thenThrow(권한_거부());

            // when
            interviewTranscriptionFacade.transcribe(answer.getId(), 키(answer));

            // then
            assertThat(답안(answer.getId()).getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.FAILED);
            verify(transcriptionModel, never()).call(any(AudioTranscriptionPrompt.class));
        }

        @Test
        void 답안이_없으면_변환하지_않고_예외를_밖으로_던지지_않는다() {
            // when & then
            assertThatCode(() -> interviewTranscriptionFacade.transcribe(UNKNOWN_ANSWER_ID, 음성_키(1L, DISPLAY_ORDER)))
                    .doesNotThrowAnyException();
            verify(transcriptionModel, never()).call(any(AudioTranscriptionPrompt.class));
        }

        @Test
        void 제출한_뒤에_결과가_도착해도_제출한_답안은_바뀌지_않는다() {
            // given
            InterviewAnswer answer = 변환_중_답안_저장(개념이_있는_문제());
            String audioKey = 키(answer);
            ReflectionTestUtils.setField(answer, "status", InterviewAnswerStatus.ANSWERED);
            ReflectionTestUtils.setField(answer, "content", SUBMITTED_CONTENT);
            ReflectionTestUtils.setField(answer, "audioKey", audioKey);
            interviewAnswerRepository.save(answer);

            // when
            interviewTranscriptionFacade.transcribe(answer.getId(), audioKey);

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
        void 재요청한_다른_변환이_먼저_끝났으면_늦은_결과를_버린다() {
            // given
            InterviewSession session = interviewSessionRepository.save(진행중_세션(USER_ID, InterviewInputType.VOICE));
            InterviewAnswer answer = interviewAnswerRepository.save(변환_완료_답안(
                    session.getId(), 개념이_있는_문제(), DISPLAY_ORDER,
                    LocalDateTime.now(clock).minusMinutes(REQUESTED_MINUTES_AGO), PREVIOUS_TRANSCRIPT));

            // when
            interviewTranscriptionFacade.transcribe(answer.getId(), 키(answer));

            // then
            InterviewAnswer result = 답안(answer.getId());
            assertSoftly(softly -> {
                softly.assertThat(result.getTranscriptionStatus()).isEqualTo(InterviewTranscriptionStatus.COMPLETED);
                softly.assertThat(result.getTranscript()).isEqualTo(PREVIOUS_TRANSCRIPT);
            });
        }
    }
}
