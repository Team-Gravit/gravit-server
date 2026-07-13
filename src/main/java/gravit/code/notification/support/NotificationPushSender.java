package gravit.code.notification.support;

import gravit.code.fcm.dto.internal.PushMessage;
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

        PushMessage pushMessage = PushMessage.of(tokens, message, null, data);

        fcmService.sendNotifications(List.of(pushMessage));
    }

    public void pushToUsers(
            List<Long> userIds,
            Map<String, String> data,
            Supplier<String> messageSupplier
    ) {
        Map<Long, List<String>> tokensByUserId = fcmTokenQueryService.getTokensByUserIds(userIds);

        List<PushMessage> messages = userIds.stream()
                .filter(tokensByUserId::containsKey)
                .map(userId -> PushMessage.of(
                        tokensByUserId.get(userId),
                        messageSupplier.get(),
                        null,
                        data
                ))
                .toList();

        fcmService.sendNotifications(messages);
    }

    // 유저별로 다른 문구를 푸시할 때 사용 (연속학습 위기·오늘 미완료)
    public void pushEach(
            Map<Long, String> messageByUserId,
            Map<String, String> data
    ) {
        Map<Long, List<String>> tokensByUserId = fcmTokenQueryService.getTokensByUserIds(List.copyOf(messageByUserId.keySet()));

        List<PushMessage> messages = messageByUserId.entrySet().stream()
                .filter(entry -> tokensByUserId.containsKey(entry.getKey()))
                .map(entry -> PushMessage.of(
                        tokensByUserId.get(entry.getKey()),
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

        PushMessage pushMessage = PushMessage.of(tokens, message, null, data);

        fcmService.sendNotifications(List.of(pushMessage));
    }
}
