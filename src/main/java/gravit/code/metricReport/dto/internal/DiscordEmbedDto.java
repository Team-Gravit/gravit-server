package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DiscordEmbedDto(

        String title,

        String url,

        String description,

        Integer color,

        List<DiscordEmbedFieldDto> fields,

        DiscordEmbedFooterDto footer
) {
    public static DiscordEmbedDto of(
            String title,
            String url,
            String description,
            Integer color,
            List<DiscordEmbedFieldDto> fields,
            DiscordEmbedFooterDto footer
    ) {
        return new DiscordEmbedDto(title, url, description, color, fields, footer);
    }
}
