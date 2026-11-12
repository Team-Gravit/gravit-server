package gravit.code.fcm.service;

import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import gravit.code.fcm.dto.internal.PushMessageDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Log4j2
@Service
@RequiredArgsConstructor
public class FcmService {

    private static final int BATCH_SIZE = 500;

    private final FirebaseMessaging firebaseMessaging;

    public void sendNotifications(List<PushMessageDto> messages) {
        List<Message> fcmMessages = messages.stream()
                .flatMap(message -> message.tokens().stream()
                        .map(token -> toMessage(token, message.title(), message.body(), message.data())))
                .toList();

        if (fcmMessages.isEmpty()) {
            return;
        }

        for (int start = 0; start < fcmMessages.size(); start += BATCH_SIZE) {
            int end = Math.min(start + BATCH_SIZE, fcmMessages.size());
            sendBatch(fcmMessages.subList(start, end));
        }
    }

    private Message toMessage(
            String token,
            String title,
            String body,
            Map<String, String> data
    ) {
        Notification.Builder notification = Notification.builder();

        if (title != null && !title.isBlank()) {
            notification.setTitle(title);
        }

        if (body != null && !body.isBlank()) {
            notification.setBody(body);
        }

        Message.Builder message = Message.builder()
                .setToken(token)
                .setNotification(notification.build());

        if (data != null && !data.isEmpty()) {
            message.putAllData(data);
        }

        return message.build();
    }

    private void sendBatch(List<Message> batch) {
        try {
            BatchResponse response = firebaseMessaging.sendEach(batch);
            if (response.getFailureCount() > 0) {
                log.warn("FCM 부분 실패 (성공 {}건 / 실패 {}건)", response.getSuccessCount(), response.getFailureCount());
            }
        } catch (FirebaseMessagingException e) {
            log.error("FCM 푸시 발송 실패 (배치 {}건)", batch.size(), e);
        }
    }
}
