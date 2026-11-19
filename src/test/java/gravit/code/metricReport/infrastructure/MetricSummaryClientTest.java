package gravit.code.metricReport.infrastructure;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import gravit.code.metricReport.config.MetricSummaryProps;
import io.micrometer.observation.ObservationRegistry;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.ai.model.openai.autoconfigure.OpenAiConnectionProperties;
import org.springframework.ai.retry.RetryUtils;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class MetricSummaryClientTest {

    private static final String METRICS = "### 👥 사용자\n신규 가입 **1명** `▼6`";
    private static final Duration TIMEOUT = Duration.ofSeconds(1);

    private HttpServer server;
    private final AtomicInteger requestCount = new AtomicInteger();
    private final List<String> requestBodies = new CopyOnWriteArrayList<>();
    private volatile int responseStatus;
    private volatile String responseContent;
    private volatile long responseDelayMillis;

    @BeforeEach
    void setUp() throws IOException {
        responseStatus = 200;
        responseContent = "요약 문장";
        responseDelayMillis = 0;

        server = HttpServer.create(new InetSocketAddress("localhost", 0), 0);
        server.createContext("/v1/chat/completions", this::respond);
        server.start();
    }

    private void respond(HttpExchange exchange) throws IOException {
        requestCount.incrementAndGet();
        requestBodies.add(new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8));

        try {
            Thread.sleep(responseDelayMillis);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        byte[] body = (responseStatus == 200 ? completion(responseContent) : "{\"error\":{\"message\":\"upstream\"}}")
                .getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.sendResponseHeaders(responseStatus, body.length);
        try (OutputStream out = exchange.getResponseBody()) {
            out.write(body);
        } catch (IOException ignored) {
            // 클라이언트가 타임아웃으로 먼저 끊은 경우
        }
    }

    private static String completion(String content) {
        String escaped = content.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
        return """
                {"id":"chatcmpl-1","object":"chat.completion","created":1,"model":"ops-analyst",
                 "choices":[{"index":0,"message":{"role":"assistant","content":"%s"},"finish_reason":"stop"}],
                 "usage":{"prompt_tokens":10,"completion_tokens":5,"total_tokens":15}}
                """.formatted(escaped);
    }

    @AfterEach
    void tearDown() {
        server.stop(0);
    }

    private MetricSummaryClient 클라이언트(boolean enabled) {
        OpenAiConnectionProperties connection = new OpenAiConnectionProperties();
        connection.setBaseUrl("http://localhost:" + server.getAddress().getPort());
        connection.setApiKey("test-key");

        return new MetricSummaryClient(
                connection,
                RetryUtils.DEFAULT_RESPONSE_ERROR_HANDLER,
                ObservationRegistry.NOOP,
                new MetricSummaryProps(enabled, "ops-analyst", TIMEOUT)
        );
    }

    @Nested
    @DisplayName("요약을 요청할 때")
    class Summarize {

        @Test
        void 정상_응답이면_앞뒤_공백을_지운_요약을_반환하고_전용_별칭으로_요청한다() {
            // given
            responseContent = "  가입이 줄었다.\n정답률이 낮다.  ";

            // when
            var summary = 클라이언트(true).summarize(METRICS);

            // then
            assertSoftly(softly -> {
                softly.assertThat(summary).contains("가입이 줄었다.\n정답률이 낮다.");
                softly.assertThat(requestBodies.getFirst()).contains("\"model\":\"ops-analyst\"");
                softly.assertThat(requestBodies.getFirst()).contains("신규 가입 **1명**");
            });
        }

        @Test
        void 게이트웨이가_500을_주면_다시_시도하지_않고_요약_없이_끝낸다() {
            // given
            responseStatus = 500;

            // when
            var summary = 클라이언트(true).summarize(METRICS);

            // then
            assertSoftly(softly -> {
                softly.assertThat(summary).isEmpty();
                softly.assertThat(requestCount.get()).isEqualTo(1);
            });
        }

        @Test
        void 응답이_타임아웃보다_늦으면_기다리지_않고_요약_없이_끝낸다() {
            // given
            responseDelayMillis = 3_000;
            long startNanos = System.nanoTime();

            // when
            var summary = 클라이언트(true).summarize(METRICS);

            // then
            long elapsedMillis = Duration.ofNanos(System.nanoTime() - startNanos).toMillis();
            assertSoftly(softly -> {
                softly.assertThat(summary).isEmpty();
                softly.assertThat(elapsedMillis).isLessThan(2_500);
            });
        }

        @Test
        void 빈_응답이면_요약이_없다() {
            // given
            responseContent = "   ";

            // when & then
            assertThat(클라이언트(true).summarize(METRICS)).isEmpty();
        }

        @Test
        void 요약이_1000자를_넘으면_자르고_말줄임표를_붙인다() {
            // given
            responseContent = "가".repeat(1_200);

            // when
            var summary = 클라이언트(true).summarize(METRICS);

            // then
            assertThat(summary).contains("가".repeat(1_000) + "…");
        }

        @Test
        void 꺼져_있으면_요청하지_않는다() {
            // when
            var summary = 클라이언트(false).summarize(METRICS);

            // then
            assertSoftly(softly -> {
                softly.assertThat(summary).isEmpty();
                softly.assertThat(requestCount.get()).isZero();
            });
        }
    }
}
