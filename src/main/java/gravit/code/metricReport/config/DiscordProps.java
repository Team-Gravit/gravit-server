package gravit.code.metricReport.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

@ConfigurationProperties(prefix = "discord")
public record DiscordProps(
        boolean reportEnabled,
        boolean interactionEnabled,
        String publicKey,
        String reportWebhookUrl,
        List<String> allowedChannelIds,
        List<String> allowedRoleIds,
        int listLimit
) {
}
