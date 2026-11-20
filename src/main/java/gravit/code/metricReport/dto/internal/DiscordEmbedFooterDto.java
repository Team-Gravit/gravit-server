package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DiscordEmbedFooterDto(

        String text
) {
    public static DiscordEmbedFooterDto from(String text) {
        return new DiscordEmbedFooterDto(text);
    }
}
