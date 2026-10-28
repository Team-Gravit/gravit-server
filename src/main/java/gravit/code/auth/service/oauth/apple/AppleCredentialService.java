package gravit.code.auth.service.oauth.apple;

import gravit.code.auth.domain.AppleClient;
import gravit.code.auth.domain.AppleCredential;
import gravit.code.auth.dto.internal.AppleStoredTokenDto;
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
            String refreshToken,
            AppleClient client
    ) {
        String encryptedRefreshToken = appleTokenCipher.encrypt(refreshToken);

        appleCredentialRepository.findByUserId(userId)
                .ifPresentOrElse(
                        credential -> credential.updateRefreshToken(encryptedRefreshToken, client),
                        () -> appleCredentialRepository.save(AppleCredential.create(userId, encryptedRefreshToken, client))
                );
    }

    @Transactional(readOnly = true)
    public Optional<AppleStoredTokenDto> findRefreshToken(long userId) {
        return appleCredentialRepository.findByUserId(userId)
                .map(credential -> AppleStoredTokenDto.of(
                        appleTokenCipher.decrypt(credential.getRefreshToken()),
                        credential.getClient()
                ));
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void deleteByUserId(long userId) {
        appleCredentialRepository.deleteByUserId(userId);
    }
}
