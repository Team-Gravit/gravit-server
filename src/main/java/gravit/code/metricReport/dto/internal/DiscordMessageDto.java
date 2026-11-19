package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DiscordMessageDto(

        String content,

        List<DiscordEmbedDto> embeds,

        List<DiscordActionRowDto> components,

        Integer flags
) {
    public static DiscordMessageDto of(
            String content,
            List<DiscordEmbedDto> embeds,
            List<DiscordActionRowDto> components,
            Integer flags
    ) {
        return new DiscordMessageDto(content, embeds, components, flags);
    }
}
