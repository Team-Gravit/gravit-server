package gravit.code.metricReport.service;

import gravit.code.metricReport.dto.internal.DiscordMessageDto;
import gravit.code.metricReport.fixture.MetricFixture;
import gravit.code.metricReport.infrastructure.DiscordWebhookClient;
import gravit.code.metricReport.infrastructure.MetricSummaryClient;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static org.assertj.core.api.SoftAssertions.assertSoftly;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

// 고정 시계 기준 now = 2025-08-05T12:00 (Asia/Seoul, 화요일)
@TCSpringBootTest
class MetricReportServiceIntegrationTest {

    private static final int FLAG_SUPPRESS_NOTIFICATIONS = 4096;

    @Autowired
    private MetricReportService metricReportService;

    @Autowired
    private MetricFixture metricFixture;

    @MockitoBean
    private DiscordWebhookClient discordWebhookClient;

    @MockitoBean
    private MetricSummaryClient metricSummaryClient;

    private DiscordMessageDto 전송된_메시지() {
        ArgumentCaptor<DiscordMessageDto> captor = ArgumentCaptor.forClass(DiscordMessageDto.class);
        verify(discordWebhookClient).send(captor.capture());
        return captor.getValue();
    }

    @Nested
    @DisplayName("정기 리포트를 보낼 때")
    class SendScheduledReport {

        @Test
        void 주간_리포트는_지난주_지표를_무음으로_보낸다() {
            // when
            metricReportService.sendWeeklyReport();

            // then
            DiscordMessageDto message = 전송된_메시지();
            assertSoftly(softly -> {
                softly.assertThat(message.flags()).isEqualTo(FLAG_SUPPRESS_NOTIFICATIONS);
                softly.assertThat(message.embeds().getFirst().title()).isEqualTo("📊 주간 리포트 · 07-28 ~ 08-03");
                softly.assertThat(message.embeds().getFirst().url()).isEqualTo("https://admin.test/");
                softly.assertThat(message.components()).isNull();
                softly.assertThat(message.embeds().getFirst().description()).doesNotContain("문제 #");
            });
        }
    }

    @Nested
    @DisplayName("AI 요약을 붙일 때")
    class Summary {

        @Test
        void 요약이_생성되면_리포트_맨_위에_붙여_보낸다() {
            // given
            when(metricSummaryClient.summarize(anyString())).thenReturn(Optional.of("지난주는 신규 가입이 없었다."));

            // when
            metricReportService.sendWeeklyReport();

            // then
            assertThat(전송된_메시지().embeds().getFirst().description())
                    .contains("> 🧠 **AI 요약**\n> 지난주는 신규 가입이 없었다.");
        }

        @Test
        void 요약이_실패하면_규칙_결론_줄로_보낸다() {
            // given
            when(metricSummaryClient.summarize(anyString())).thenReturn(Optional.empty());

            // when
            metricReportService.sendWeeklyReport();

            // then
            assertThat(전송된_메시지().embeds().getFirst().description())
                    .doesNotContain("AI 요약")
                    .contains("> ");
        }

        @Test
        void 요약_입력에는_사용자가_쓴_문의_제목이_들어가지_않는다() {
            // given
            metricFixture.문의("OTHER", "홍길동 계정 문의", "PENDING", LocalDateTime.of(2025, 8, 1, 10, 0));
            ArgumentCaptor<String> inputCaptor = ArgumentCaptor.forClass(String.class);

            // when
            metricReportService.sendWeeklyReport();

            // then
            verify(metricSummaryClient).summarize(inputCaptor.capture());
            assertThat(inputCaptor.getValue())
                    .contains("미답변 문의 **1건**")
                    .doesNotContain("홍길동 계정 문의");
        }
    }
}
