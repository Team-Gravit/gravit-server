package gravit.code.security.config;

import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.actuate.observability.AutoConfigureObservability;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalManagementPort;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static gravit.code.global.exception.domain.CustomErrorCode.TOKEN_EMPTY;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "management.server.port=0",
                "management.endpoints.web.exposure.include=health,prometheus"
        }
)
@AutoConfigureObservability(tracing = false)
@ExtendWith(OutputCaptureExtension.class)
class SecurityConfigManagementPortIntegrationTest {

    private static final String LOCAL_URL_FORMAT = "http://localhost:%d%s";

    private static final String PROMETHEUS_URI = "/actuator/prometheus";
    private static final String HEALTH_URI = "/actuator/health";
    private static final String API_URI = "/api/v1/version";

    private static final String INVALID_BEARER_TOKEN = "Bearer invalid-token";

    private static final String PROMETHEUS_HELP_LINE = "# HELP";
    private static final String HEALTH_UP = "\"status\":\"UP\"";

    private static final String REQUEST_LOG_PREFIX = "[REQUEST] GET ";
    private static final String API_PERF_LOG_PREFIX = "uri=";
    private static final String ERROR_LOG = "예외 발생";

    @LocalServerPort
    private int serverPort;

    @LocalManagementPort
    private int managementPort;

    @Autowired
    private TestRestTemplate restTemplate;

    @Nested
    @DisplayName("관리 포트로 요청할 때")
    class ManagementPort {

        @Test
        void 인증_없이_prometheus_메트릭을_응답한다() {
            // when
            ResponseEntity<String> response = 요청(managementPort, PROMETHEUS_URI);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
                softly.assertThat(response.getBody()).contains(PROMETHEUS_HELP_LINE);
            });
        }

        @Test
        void 유효하지_않은_토큰이_있어도_prometheus_메트릭을_응답한다() {
            // when
            ResponseEntity<String> response = 토큰_요청(managementPort, PROMETHEUS_URI, INVALID_BEARER_TOKEN);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
                softly.assertThat(response.getBody()).contains(PROMETHEUS_HELP_LINE);
            });
        }

        @Test
        void 인증_없이_health를_응답한다() {
            // when
            ResponseEntity<String> response = 요청(managementPort, HEALTH_URI);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
                softly.assertThat(response.getBody()).contains(HEALTH_UP);
            });
        }

        @Test
        void 요청_로그와_API_성능_로그를_남기지_않는다(CapturedOutput output) {
            // given
            요청(serverPort, API_URI);

            // when
            요청(managementPort, PROMETHEUS_URI);

            // then
            assertSoftly(softly -> {
                softly.assertThat(output.getOut()).contains(REQUEST_LOG_PREFIX + API_URI);
                softly.assertThat(output.getOut()).contains(API_PERF_LOG_PREFIX + API_URI);
                softly.assertThat(output.getOut()).doesNotContain(REQUEST_LOG_PREFIX + PROMETHEUS_URI);
                softly.assertThat(output.getOut()).doesNotContain(API_PERF_LOG_PREFIX + PROMETHEUS_URI);
            });
        }
    }

    @Nested
    @DisplayName("메인 포트로 요청할 때")
    class MainPort {

        @ParameterizedTest
        @ValueSource(strings = {PROMETHEUS_URI, HEALTH_URI})
        void actuator_경로는_401과_TOKEN_EMPTY를_응답한다(String uri) {
            // when
            ResponseEntity<String> response = 요청(serverPort, uri);

            // then
            assertSoftly(softly -> {
                softly.assertThat(response.getStatusCode().value()).isEqualTo(TOKEN_EMPTY.getHttpStatus().value());
                softly.assertThat(response.getBody()).contains(TOKEN_EMPTY.getCode());
                softly.assertThat(response.getBody()).doesNotContain(PROMETHEUS_HELP_LINE);
            });
        }

        @Test
        void actuator_경로는_에러_로그를_남기지_않는다(CapturedOutput output) {
            // when
            요청(serverPort, PROMETHEUS_URI);

            // then
            assertThat(output.getOut()).doesNotContain(ERROR_LOG);
        }
    }

    private ResponseEntity<String> 요청(
            int port,
            String uri
    ) {
        return restTemplate.getForEntity(LOCAL_URL_FORMAT.formatted(port, uri), String.class);
    }

    private ResponseEntity<String> 토큰_요청(
            int port,
            String uri,
            String authorization
    ) {
        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.AUTHORIZATION, authorization);
        return restTemplate.exchange(
                LOCAL_URL_FORMAT.formatted(port, uri),
                HttpMethod.GET,
                new HttpEntity<>(headers),
                String.class
        );
    }
}
