package gravit.code.user.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import gravit.code.user.infrastructure.RedisUserCleanManager;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserDeletionService {
    private final UserRepository userRepository;
    private final RedisUserCleanManager cleanManager;
    private final DeletionAuthCodeManager authCodeManager;
    private final DeletionMailManager deletionMailManager;

    public void requestDeletion(long userId, String dest){
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        String authCode = authCodeManager.generate(userId);

        try{
            deletionMailManager.requestDeletion(user.getEmail(), dest, authCode);
        } catch (RestApiException e){
            throw new RestApiException(CustomErrorCode.MAIL_SEND_ERROR);
        }
    }

    @Transactional
    public void confirmAndDelete(String authCode) {
        long userId = authCodeManager.verify(authCode);

        // 유저가 조회되면(Active 상태로 존재하면) soft delete
        userRepository.findById(userId)
                .ifPresent(user -> userRepository.deleteById(user.getId()));

        cleanManager.storeDeletionUser(userId);
    }

    @Transactional
    public void executeHardDelete(long userId) {
        userRepository.cleanUserDeletion(userId);
    }
}
