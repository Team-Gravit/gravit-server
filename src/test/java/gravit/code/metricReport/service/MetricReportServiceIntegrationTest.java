package gravit.code.metricReport.service;

import gravit.code.metricReport.dto.internal.DiscordMessageDto;
import gravit.code.metricReport.infrastructure.DiscordWebhookClient;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.mockito.Mockito.verify;

// 고정 시계 기준 now = 2025-08-05T12:00 (Asia/Seoul, 화요일)
@TCSpringBootTest
class MetricReportServiceIntegrationTest {

    private static final int FLAG_SUPPRESS_NOTIFICATIONS = 4096;

    @Autowired
    private MetricReportService metricReportService;

    @MockitoBean
    private DiscordWebhookClient discordWebhookClient;

    private DiscordMessageDto 전송된_메시지() {
        ArgumentCaptor<DiscordMessageDto> captor = ArgumentCaptor.forClass(DiscordMessageDto.class);
        verify(discordWebhookClient).send(captor.capture());
        return captor.getValue();
    }

    @Nested
    @DisplayName("정기 리포트를 보낼 때")
    class SendScheduledReport {

        @Test
        void 일간_리포트는_어제_지표를_무음으로_보낸다() {
            // when
            metricReportService.sendDailyReport();

            // then
            DiscordMessageDto message = 전송된_메시지();
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_SUPPRESS_NOTIFICATIONS);
                softly.assertThat(message.embeds().getFirst().title()).isEqualTo("📊 일간 리포트 · 2025-08-04");
            });
        }

        @Test
        void 주간_리포트는_지난주_지표를_무음으로_보낸다() {
            // when
            metricReportService.sendWeeklyReport();

            // then
            DiscordMessageDto message = 전송된_메시지();
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_SUPPRESS_NOTIFICATIONS);
                softly.assertThat(message.embeds().getFirst().title()).isEqualTo("📊 주간 리포트 · 07-28 ~ 08-03");
            });
        }
    }
}
