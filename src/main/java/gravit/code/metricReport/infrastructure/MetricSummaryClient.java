package gravit.code.metricReport.infrastructure;

import gravit.code.metricReport.config.MetricSummaryProps;
import io.micrometer.observation.ObservationRegistry;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.model.openai.autoconfigure.OpenAiConnectionProperties;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.openai.api.OpenAiApi;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.retry.support.RetryTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResponseErrorHandler;
import org.springframework.web.client.RestClient;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.Optional;

@Slf4j
@Component
public class MetricSummaryClient {

    private static final Resource SYSTEM_PROMPT = new ClassPathResource("prompts/metric-summary-system.st");
    private static final Resource USER_PROMPT = new ClassPathResource("prompts/metric-summary-user.st");
    private static final String PARAM_METRICS = "metrics";
    private static final Duration CONNECT_TIMEOUT = Duration.ofSeconds(3);
    private static final int SINGLE_ATTEMPT = 1;
    private static final double TEMPERATURE = 0.2;
    private static final int SUMMARY_MAX_LENGTH = 1000;
    private static final String TRUNCATION_SUFFIX = "…";

    private final ChatClient chatClient;
    private final boolean enabled;

    public MetricSummaryClient(
            OpenAiConnectionProperties connectionProperties,
            ResponseErrorHandler responseErrorHandler,
            ObservationRegistry observationRegistry,
            MetricSummaryProps metricSummaryProps
    ) {
        this.enabled = metricSummaryProps.enabled();
        this.chatClient = ChatClient.create(createChatModel(connectionProperties, responseErrorHandler, observationRegistry, metricSummaryProps));
    }

    private static OpenAiChatModel createChatModel(
            OpenAiConnectionProperties connectionProperties,
            ResponseErrorHandler responseErrorHandler,
            ObservationRegistry observationRegistry,
            MetricSummaryProps metricSummaryProps
    ) {
        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(CONNECT_TIMEOUT)
                .build();
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(httpClient);
        requestFactory.setReadTimeout(metricSummaryProps.timeout());

        OpenAiApi openAiApi = OpenAiApi.builder()
                .baseUrl(connectionProperties.getBaseUrl())
                .apiKey(connectionProperties.getApiKey())
                .restClientBuilder(RestClient.builder().requestFactory(requestFactory))
                .responseErrorHandler(responseErrorHandler)
                .build();

        return OpenAiChatModel.builder()
                .openAiApi(openAiApi)
                .defaultOptions(OpenAiChatOptions.builder().model(metricSummaryProps.model()).temperature(TEMPERATURE).build())
                .retryTemplate(RetryTemplate.builder().maxAttempts(SINGLE_ATTEMPT).build())
                .observationRegistry(observationRegistry)
                .build();
    }

    public Optional<String> summarize(String metricsText) {
        if (!enabled) {
            return Optional.empty();
        }

        long startNanos = System.nanoTime();
        try {
            String content = chatClient.prompt()
                    .system(SYSTEM_PROMPT)
                    .user(user -> user.text(USER_PROMPT).param(PARAM_METRICS, metricsText))
                    .call()
                    .content();

            log.info("지표 요약 생성 완료 - elapsedMs: {}", Duration.ofNanos(System.nanoTime() - startNanos).toMillis());
            return normalize(content);
        } catch (RuntimeException e) {
            log.warn("지표 요약 생성 실패 - {}", e.getClass().getSimpleName());
            return Optional.empty();
        }
    }

    private Optional<String> normalize(String content) {
        if (content == null || content.isBlank()) {
            return Optional.empty();
        }

        String summary = content.strip();
        if (summary.length() <= SUMMARY_MAX_LENGTH) {
            return Optional.of(summary);
        }

        return Optional.of(summary.substring(0, SUMMARY_MAX_LENGTH) + TRUNCATION_SUFFIX);
    }
}
