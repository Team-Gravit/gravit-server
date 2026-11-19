package gravit.code.metricReport.controller;

import gravit.code.metricReport.fixture.DiscordTestKey;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static gravit.code.global.exception.domain.CustomErrorCode.DISCORD_INVALID_SIGNATURE;
import static gravit.code.global.exception.domain.CustomErrorCode.DISCORD_UNSUPPORTED_INTERACTION;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// application-test.yml: 허용 채널 test-channel, 허용 역할 test-role
@TCSpringBootTest
@AutoConfigureMockMvc
class DiscordInteractionControllerIntegrationTest {

    private static final String URI = "/api/v1/discord/interactions";
    private static final String SIGNATURE_HEADER = "X-Signature-Ed25519";
    private static final String TIMESTAMP_HEADER = "X-Signature-Timestamp";
    private static final String TIMESTAMP = "1754362800";
    private static final String PING = "{\"type\":1}";
    private static final int FLAG_EPHEMERAL = 64;
    private static final int FLAG_SUPPRESS_NOTIFICATIONS = 4096;
    private static final String ADMIN_URL = "https://admin.test/";

    @Autowired
    private MockMvc mockMvc;

    private ResultActions 서명해서_보낸다(String body) throws Exception {
        return mockMvc.perform(post(URI)
                .contentType(MediaType.APPLICATION_JSON)
                .header(SIGNATURE_HEADER, DiscordTestKey.서명(TIMESTAMP, body))
                .header(TIMESTAMP_HEADER, TIMESTAMP)
                .content(body));
    }

    private static String 현황_명령(
            String channelId,
            String roleId,
            String periodOption
    ) {
        String options = periodOption == null
                ? ""
                : ",\"options\":[{\"type\":3,\"name\":\"기간\",\"value\":\"" + periodOption + "\"}]";

        return "{\"type\":2,\"channel_id\":\"" + channelId + "\","
                + "\"member\":{\"roles\":[\"" + roleId + "\"],\"user\":{\"id\":\"1\"}},"
                + "\"data\":{\"id\":\"10\",\"name\":\"현황\",\"type\":1" + options + "}}";
    }

    private static String 공유_버튼(String customId) {
        return "{\"type\":3,\"channel_id\":\"test-channel\","
                + "\"member\":{\"roles\":[\"test-role\"]},"
                + "\"data\":{\"custom_id\":\"" + customId + "\",\"component_type\":2}}";
    }

    @Nested
    @DisplayName("요청 서명을 확인할 때")
    class Signature {

        @Test
        void 디스코드의_PING에는_PONG으로_응답한다() throws Exception {
            // when & then
            서명해서_보낸다(PING)
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.type").value(1))
                    .andExpect(jsonPath("$.data").doesNotExist());
        }

        @Test
        void 서명이_틀리면_JWT_없이도_401을_반환한다() throws Exception {
            // when & then
            mockMvc.perform(post(URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .header(SIGNATURE_HEADER, DiscordTestKey.서명(TIMESTAMP, "{\"type\":2}"))
                            .header(TIMESTAMP_HEADER, TIMESTAMP)
                            .content(PING))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(DISCORD_INVALID_SIGNATURE.getCode()));
        }

        @Test
        void 서명_헤더가_없으면_401을_반환한다() throws Exception {
            // when & then
            mockMvc.perform(post(URI)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(PING))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.error").value(DISCORD_INVALID_SIGNATURE.getCode()));
        }
    }

    @Nested
    @DisplayName("현황 명령을 받을 때")
    class StatusCommand {

        @Test
        void 허용된_채널과_역할이면_요청자만_보는_현황과_공유_버튼으로_응답한다() throws Exception {
            // when & then
            서명해서_보낸다(현황_명령("test-channel", "test-role", "7d"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.type").value(4))
                    .andExpect(jsonPath("$.data.flags").value(FLAG_EPHEMERAL))
                    .andExpect(jsonPath("$.data.embeds[0].title").value("📊 서비스 현황 · 최근 7일"))
                    .andExpect(jsonPath("$.data.embeds[0].url").value(ADMIN_URL))
                    .andExpect(jsonPath("$.data.embeds[0].description").value(startsWith("-# 07-29 ~ 08-04 · 직전 같은 기간(07-22 ~ 07-28) 대비")))
                    .andExpect(jsonPath("$.data.embeds[0].fields").doesNotExist())
                    .andExpect(jsonPath("$.data.components[0].type").value(1))
                    .andExpect(jsonPath("$.data.components[0].components[0].custom_id").value("metric-share:7d"))
                    .andExpect(jsonPath("$.data.components[0].components[1].custom_id").value("metric-list:7d"))
                    .andExpect(jsonPath("$.data.components[0].components[2].style").value(5))
                    .andExpect(jsonPath("$.data.components[0].components[2].url").value(ADMIN_URL));
        }

        @Test
        void 기간을_고르지_않으면_오늘_현황으로_응답한다() throws Exception {
            // when & then
            서명해서_보낸다(현황_명령("test-channel", "test-role", null))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.embeds[0].title").value("📊 서비스 현황 · 오늘"))
                    .andExpect(jsonPath("$.data.components[0].components[0].custom_id").value("metric-share:today"));
        }

        @Test
        void 허용되지_않은_채널이면_거부_안내만_요청자에게_보인다() throws Exception {
            // when & then
            서명해서_보낸다(현황_명령("other-channel", "test-role", "7d"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.type").value(4))
                    .andExpect(jsonPath("$.data.flags").value(FLAG_EPHEMERAL))
                    .andExpect(jsonPath("$.data.content").value("이 채널이나 역할에서는 현황을 조회할 수 없습니다."))
                    .andExpect(jsonPath("$.data.embeds").doesNotExist());
        }

        @Test
        void 허용된_역할이_없으면_거부_안내만_요청자에게_보인다() throws Exception {
            // when & then
            서명해서_보낸다(현황_명령("test-channel", "other-role", "7d"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.content").value("이 채널이나 역할에서는 현황을 조회할 수 없습니다."))
                    .andExpect(jsonPath("$.data.embeds").doesNotExist());
        }

        @Test
        void DM처럼_멤버_정보가_없으면_거부한다() throws Exception {
            // given
            String body = "{\"type\":2,\"channel_id\":\"test-channel\",\"user\":{\"id\":\"1\"},\"data\":{\"name\":\"현황\"}}";

            // when & then
            서명해서_보낸다(body)
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.content").value("이 채널이나 역할에서는 현황을 조회할 수 없습니다."));
        }

        @Test
        void 모르는_명령이면_400을_반환한다() throws Exception {
            // given
            String body = "{\"type\":2,\"channel_id\":\"test-channel\",\"member\":{\"roles\":[\"test-role\"]},\"data\":{\"name\":\"질문\"}}";

            // when & then
            서명해서_보낸다(body)
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(DISCORD_UNSUPPORTED_INTERACTION.getCode()));
        }

        @Test
        void 모르는_기간_값이면_400을_반환한다() throws Exception {
            // when & then
            서명해서_보낸다(현황_명령("test-channel", "test-role", "90d"))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(DISCORD_UNSUPPORTED_INTERACTION.getCode()));
        }
    }

    @Nested
    @DisplayName("공유와 목록 버튼을 받을 때")
    class ShareButton {

        @Test
        void 같은_기간을_다시_집계해_채널에_무음으로_공개한다() throws Exception {
            // when & then
            서명해서_보낸다(공유_버튼("metric-share:yesterday"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.type").value(4))
                    .andExpect(jsonPath("$.data.flags").value(FLAG_SUPPRESS_NOTIFICATIONS))
                    .andExpect(jsonPath("$.data.embeds[0].title").value("📊 서비스 현황 · 어제"))
                    .andExpect(jsonPath("$.data.components[0].components.length()").value(1))
                    .andExpect(jsonPath("$.data.components[0].components[0].url").value(ADMIN_URL));
        }

        @Test
        void 목록_버튼은_같은_기간의_신고와_문의_목록을_요청자에게만_보여준다() throws Exception {
            // when & then
            서명해서_보낸다(공유_버튼("metric-list:yesterday"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.type").value(4))
                    .andExpect(jsonPath("$.data.flags").value(FLAG_EPHEMERAL))
                    .andExpect(jsonPath("$.data.embeds[0].title").value("🗂️ 신고·문의 목록 · 어제"))
                    .andExpect(jsonPath("$.data.embeds[0].fields.length()").value(2))
                    .andExpect(jsonPath("$.data.embeds[0].fields[0].value").value("신규 0건 · 미처리 총 0건\n새로 들어온 신고 없음"));
        }

        @Test
        void 허용되지_않은_채널에서_목록_버튼을_누르면_거부한다() throws Exception {
            // given
            String body = "{\"type\":3,\"channel_id\":\"other-channel\","
                    + "\"member\":{\"roles\":[\"test-role\"]},"
                    + "\"data\":{\"custom_id\":\"metric-list:7d\",\"component_type\":2}}";

            // when & then
            서명해서_보낸다(body)
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.content").value("이 채널이나 역할에서는 현황을 조회할 수 없습니다."));
        }

        @Test
        void 공유나_목록_버튼이_아닌_컴포넌트면_400을_반환한다() throws Exception {
            // when & then
            서명해서_보낸다(공유_버튼("other-button"))
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(DISCORD_UNSUPPORTED_INTERACTION.getCode()));
        }
    }

    @Nested
    @DisplayName("지원하지 않는 요청을 받을 때")
    class Unsupported {

        @Test
        void 처리하지_않는_인터랙션_종류면_400을_반환한다() throws Exception {
            // when & then
            서명해서_보낸다("{\"type\":4,\"data\":{\"name\":\"현황\"}}")
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(DISCORD_UNSUPPORTED_INTERACTION.getCode()));
        }

        @Test
        void 본문이_JSON이_아니면_400을_반환한다() throws Exception {
            // when & then
            서명해서_보낸다("not-json")
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.error").value(DISCORD_UNSUPPORTED_INTERACTION.getCode()));
        }
    }
}
