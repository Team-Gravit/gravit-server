package gravit.code.auth.service.oauth.apple;

import gravit.code.auth.domain.AppleCredential;
import gravit.code.auth.repository.AppleCredentialRepository;
import gravit.code.auth.support.AppleTokenCipher;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AppleCredentialService {

    private final AppleCredentialRepository appleCredentialRepository;

    private final AppleTokenCipher appleTokenCipher;

    @Transactional
    public void save(
            long userId,
            String refreshToken
    ) {
        String encryptedRefreshToken = appleTokenCipher.encrypt(refreshToken);

        appleCredentialRepository.findByUserId(userId)
                .ifPresentOrElse(
                        credential -> credential.updateRefreshToken(encryptedRefreshToken),
                        () -> appleCredentialRepository.save(AppleCredential.create(userId, encryptedRefreshToken))
                );
    }

    @Transactional(readOnly = true)
    public Optional<String> findRefreshToken(long userId) {
        return appleCredentialRepository.findByUserId(userId)
                .map(credential -> appleTokenCipher.decrypt(credential.getRefreshToken()));
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void deleteByUserId(long userId) {
        appleCredentialRepository.deleteByUserId(userId);
    }
}
