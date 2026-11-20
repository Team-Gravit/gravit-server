package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DiscordEmbedFieldDto(

        String name,

        String value,

        boolean inline
) {
    public static DiscordEmbedFieldDto of(
            String name,
            String value
    ) {
        return new DiscordEmbedFieldDto(name, value, false);
    }
}
