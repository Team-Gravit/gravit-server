package gravit.code.fcm.service;

import gravit.code.fcm.domain.FcmToken;
import gravit.code.fcm.dto.request.RegisterFcmTokenRequest;
import gravit.code.fcm.repository.FcmTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FcmTokenCommandService {

    private final FcmTokenRepository fcmTokenRepository;

    @Transactional
    public void registerFcmToken(
            long userId,
            RegisterFcmTokenRequest request
    ) {
        FcmToken fcmToken = fcmTokenRepository.findByDeviceId(request.deviceId())
                .orElseGet(() -> FcmToken.create(userId, request.deviceId(), request.fcmToken(), request.platform()));

        fcmToken.updateOwnerAndToken(userId, request.fcmToken(), request.platform());

        fcmTokenRepository.save(fcmToken);
    }
}
