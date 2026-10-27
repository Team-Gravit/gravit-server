package gravit.code.interview.infrastructure;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.audio.transcription.AudioTranscriptionPrompt;
import org.springframework.ai.openai.OpenAiAudioTranscriptionModel;
import org.springframework.ai.openai.OpenAiAudioTranscriptionOptions;
import org.springframework.ai.openai.api.OpenAiAudioApi.TranscriptResponseFormat;
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
    private static final String JSON_OBJECT_PREFIX = "{";
    private static final String TEXT_FIELD = "text";

    private final OpenAiAudioTranscriptionModel transcriptionModel;
    private final ObjectMapper objectMapper;

    public String transcribe(
            String audioKey,
            byte[] audio,
            List<String> conceptNames
    ) {
        try {
            AudioTranscriptionPrompt prompt = new AudioTranscriptionPrompt(toResource(audioKey, audio), buildOptions(conceptNames));

            String output = transcriptionModel.call(prompt).getResult().getOutput();

            return unwrapText(output);
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

    private OpenAiAudioTranscriptionOptions buildOptions(List<String> conceptNames) {
        OpenAiAudioTranscriptionOptions.Builder builder = OpenAiAudioTranscriptionOptions.builder()
                .responseFormat(TranscriptResponseFormat.JSON);

        if (!conceptNames.isEmpty()) {
            builder.prompt(PROMPT_FORMAT.formatted(String.join(CONCEPT_SEPARATOR, conceptNames)));
        }

        return builder.build();
    }

    private String unwrapText(String output) {
        if (output == null || !output.strip().startsWith(JSON_OBJECT_PREFIX)) {
            return output;
        }

        try {
            JsonNode node = objectMapper.readTree(output);
            if (node.isObject() && node.hasNonNull(TEXT_FIELD)) {
                return node.get(TEXT_FIELD).asText();
            }
            return output;
        } catch (JsonProcessingException e) {
            return output;
        }
    }
}
