package gravit.code.metricReport.infrastructure;

import gravit.code.metricReport.config.DiscordProps;
import gravit.code.metricReport.dto.internal.DiscordMessageDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

@Slf4j
@Component
@RequiredArgsConstructor
public class DiscordWebhookClient {

    private final RestClient restClient;
    private final DiscordProps discordProps;

    public void send(DiscordMessageDto message) {
        String webhookUrl = discordProps.reportWebhookUrl();
        if (!StringUtils.hasText(webhookUrl)) {
            log.warn("디스코드 리포트 웹훅 URL이 비어 있어 전송하지 않음");
            return;
        }

        try {
            restClient.post()
                    .uri(webhookUrl)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(message)
                    .retrieve()
                    .toBodilessEntity();
        } catch (RestClientResponseException e) {
            log.error("디스코드 리포트 웹훅 전송 실패 - status: {}, body: {}", e.getStatusCode().value(), e.getResponseBodyAsString());
        } catch (RestClientException e) {
            log.error("디스코드 리포트 웹훅 전송 실패 - {}", e.getClass().getSimpleName());
        }
    }
}
