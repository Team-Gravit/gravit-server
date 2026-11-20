package gravit.code.metricReport.dto.internal;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record DiscordInteractionResponseDto(

        int type,

        DiscordMessageDto data
) {
    public static final int TYPE_PONG = 1;
    public static final int TYPE_CHANNEL_MESSAGE = 4;

    public static DiscordInteractionResponseDto pong() {
        return new DiscordInteractionResponseDto(TYPE_PONG, null);
    }

    public static DiscordInteractionResponseDto message(DiscordMessageDto message) {
        return new DiscordInteractionResponseDto(TYPE_CHANNEL_MESSAGE, message);
    }
}
