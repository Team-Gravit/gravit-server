package gravit.code.interview.infrastructure;

import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.audio.transcription.AudioTranscriptionPrompt;
import org.springframework.ai.openai.OpenAiAudioTranscriptionModel;
import org.springframework.ai.openai.OpenAiAudioTranscriptionOptions;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INTERVIEW_TRANSCRIPTION_FAILED;

@Slf4j
@Component
@RequiredArgsConstructor
public class InterviewTranscriptionClient {

    private static final String PROMPT_FORMAT = "CS 기술 면접 답변입니다. 다음 용어가 나올 수 있습니다: %s";
    private static final String CONCEPT_SEPARATOR = ", ";
    private static final String KEY_PATH_SEPARATOR = "/";

    private final OpenAiAudioTranscriptionModel transcriptionModel;

    public String transcribe(
            String audioKey,
            byte[] audio,
            List<String> conceptNames
    ) {
        try {
            AudioTranscriptionPrompt prompt = buildPrompt(toResource(audioKey, audio), conceptNames);

            return transcriptionModel.call(prompt).getResult().getOutput();
        } catch (RuntimeException e) {
            log.error("면접 답변 음성 변환 호출 실패 - audioKey: {}", audioKey, e);
            throw new RestApiException(INTERVIEW_TRANSCRIPTION_FAILED);
        }
    }

    private Resource toResource(
            String audioKey,
            byte[] audio
    ) {
        String fileName = audioKey.substring(audioKey.lastIndexOf(KEY_PATH_SEPARATOR) + 1);

        return new ByteArrayResource(audio) {
            @Override
            public String getFilename() {
                return fileName;
            }
        };
    }

    private AudioTranscriptionPrompt buildPrompt(
            Resource audio,
            List<String> conceptNames
    ) {
        if (conceptNames.isEmpty()) {
            return new AudioTranscriptionPrompt(audio);
        }

        OpenAiAudioTranscriptionOptions options = OpenAiAudioTranscriptionOptions.builder()
                .prompt(PROMPT_FORMAT.formatted(String.join(CONCEPT_SEPARATOR, conceptNames)))
                .build();

        return new AudioTranscriptionPrompt(audio, options);
    }
}
