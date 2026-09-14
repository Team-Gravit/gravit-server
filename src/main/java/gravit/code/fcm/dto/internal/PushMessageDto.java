package gravit.code.fcm.dto.internal;

import java.util.List;
import java.util.Map;

public record PushMessageDto(
        List<String> tokens,

        String title,

        String body,

        Map<String, String> data
) {
    public PushMessageDto {
        tokens = List.copyOf(tokens);
        data = Map.copyOf(data);
    }

    public static PushMessageDto of(
            List<String> tokens,
            String title,
            String body,
            Map<String, String> data
    ) {
        return new PushMessageDto(tokens, title, body, data);
    }

    public static PushMessageDto of(
            List<String> tokens,
            String title,
            String body
    ) {
        return new PushMessageDto(tokens, title, body, Map.of());
    }
}
