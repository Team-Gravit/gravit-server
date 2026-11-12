package gravit.code.global.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.model.openai.autoconfigure.OpenAiAudioTranscriptionProperties;
import org.springframework.ai.model.openai.autoconfigure.OpenAiConnectionProperties;
import org.springframework.ai.openai.OpenAiAudioTranscriptionModel;
import org.springframework.ai.openai.api.OpenAiAudioApi;
import org.springframework.ai.retry.TransientAiException;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.retry.support.RetryTemplate;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.ResponseErrorHandler;
import org.springframework.web.client.RestClient;

import java.time.Duration;
import java.util.List;

@Configuration
public class AiConfig {

    private static final int TRANSCRIPTION_MAX_ATTEMPTS = 3;
    private static final Duration TRANSCRIPTION_INITIAL_BACKOFF = Duration.ofSeconds(2);
    private static final double TRANSCRIPTION_BACKOFF_MULTIPLIER = 5;
    private static final Duration TRANSCRIPTION_MAX_BACKOFF = Duration.ofSeconds(10);

    @Bean
    public ChatClient chatClient(ChatModel chatModel) {
        return ChatClient.create(chatModel);
    }

    @Bean
    public OpenAiAudioTranscriptionModel transcriptionModel(
            OpenAiConnectionProperties connectionProperties,
            OpenAiAudioTranscriptionProperties transcriptionProperties,
            ObjectProvider<RestClient.Builder> restClientBuilderProvider,
            ResponseErrorHandler responseErrorHandler
    ) {
        OpenAiAudioApi audioApi = OpenAiAudioApi.builder()
                .baseUrl(connectionProperties.getBaseUrl())
                .apiKey(connectionProperties.getApiKey())
                .restClientBuilder(restClientBuilderProvider.getIfAvailable(RestClient::builder))
                .responseErrorHandler(responseErrorHandler)
                .build();

        RetryTemplate retryTemplate = RetryTemplate.builder()
                .maxAttempts(TRANSCRIPTION_MAX_ATTEMPTS)
                .exponentialBackoff(TRANSCRIPTION_INITIAL_BACKOFF, TRANSCRIPTION_BACKOFF_MULTIPLIER, TRANSCRIPTION_MAX_BACKOFF)
                .retryOn(List.of(TransientAiException.class, ResourceAccessException.class))
                .build();

        return new OpenAiAudioTranscriptionModel(audioApi, transcriptionProperties.getOptions(), retryTemplate);
    }
}
