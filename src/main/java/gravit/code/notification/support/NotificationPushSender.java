package gravit.code.notification.support;

import gravit.code.fcm.dto.internal.PushMessageDto;
import gravit.code.fcm.service.FcmService;
import gravit.code.fcm.service.FcmTokenQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.function.Supplier;

@Component
@RequiredArgsConstructor
public class NotificationPushSender {

    private final FcmTokenQueryService fcmTokenQueryService;
    private final FcmService fcmService;

    public void pushToUser(
            long userId,
            Map<String, String> data,
            String message
    ) {
        List<String> tokens = fcmTokenQueryService.getTokensByUserIds(List.of(userId))
                .get(userId);

        if (tokens == null || tokens.isEmpty()) {
            return;
        }

        PushMessageDto pushMessage = PushMessageDto.of(tokens, message, null, data);

        fcmService.sendNotifications(List.of(pushMessage));
    }

    public void pushToUsers(
            List<Long> userIds,
            Map<String, String> data,
            Supplier<String> messageSupplier
    ) {
        Map<Long, List<String>> userIdToTokens = fcmTokenQueryService.getTokensByUserIds(userIds);

        List<PushMessageDto> messages = userIds.stream()
                .filter(userIdToTokens::containsKey)
                .map(userId -> PushMessageDto.of(
                        userIdToTokens.get(userId),
                        messageSupplier.get(),
                        null,
                        data
                ))
                .toList();

        fcmService.sendNotifications(messages);
    }

    public void pushEach(
            Map<Long, String> userIdToMessage,
            Map<String, String> data
    ) {
        Map<Long, List<String>> userIdToTokens = fcmTokenQueryService.getTokensByUserIds(List.copyOf(userIdToMessage.keySet()));

        List<PushMessageDto> messages = userIdToMessage.entrySet().stream()
                .filter(entry -> userIdToTokens.containsKey(entry.getKey()))
                .map(entry -> PushMessageDto.of(
                        userIdToTokens.get(entry.getKey()),
                        entry.getValue(),
                        null,
                        data
                ))
                .toList();

        fcmService.sendNotifications(messages);
    }

    public void broadcastToAll(
            Map<String, String> data,
            String message
    ) {
        List<String> tokens = fcmTokenQueryService.getAllTokens();

        if (tokens.isEmpty()) {
            return;
        }

        PushMessageDto pushMessage = PushMessageDto.of(tokens, message, null, data);

        fcmService.sendNotifications(List.of(pushMessage));
    }
}
