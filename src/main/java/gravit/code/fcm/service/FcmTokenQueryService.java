package gravit.code.fcm.service;

import gravit.code.fcm.domain.FcmToken;
import gravit.code.fcm.dto.response.FcmTokenExistsResponse;
import gravit.code.fcm.repository.FcmTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FcmTokenQueryService {

    private final FcmTokenRepository fcmTokenRepository;

    @Transactional(readOnly = true)
    public FcmTokenExistsResponse checkFcmTokenExist(
            long userId,
            String deviceId
    ) {
        boolean registered = fcmTokenRepository.existsByUserIdAndDeviceId(userId, deviceId);

        return FcmTokenExistsResponse.create(registered);
    }

    @Transactional(readOnly = true)
    public Map<Long, List<String>> getTokensByUserIds(List<Long> userIds) {
        return fcmTokenRepository.findAndroidTokensByUserIdIn(userIds).stream()
                .collect(Collectors.groupingBy(
                        FcmToken::getUserId,
                        Collectors.mapping(FcmToken::getToken, Collectors.toList())
                ));
    }

    @Transactional(readOnly = true)
    public List<String> getAllTokens() {
        return fcmTokenRepository.findAllAndroidTokens();
    }
}
