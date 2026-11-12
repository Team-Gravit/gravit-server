package gravit.code.auth.service;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.LoginClient;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.service.port.RefreshTokenStore;
import gravit.code.auth.token.JwtProvider;
import gravit.code.auth.token.config.TokenProperties;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AuthTokenProvider {

    private static final String ROLE_CLAIM_KEY = "role";
    private static final String CLIENT_CLAIM_KEY = "client";

    private final UserRepository userRepository;

    private final JwtProvider jwtProvider;
    private final RefreshTokenStore refreshTokenStore;

    private final TokenProperties tokenProperties;

    public AccessToken generateAccessToken(User user){
        Subject subject = toSubject(user);
        Role role = user.getRole();
        String token = jwtProvider.generateToken(
                subject,
                Map.of(ROLE_CLAIM_KEY, role.name()),
                tokenProperties.access().expireTime());
        return new AccessToken(token);
    }

    public RefreshToken generateRefreshToken(
            User user,
            LoginClient client
    ) {
        Subject subject = toSubject(user);
        Duration expireTime = tokenProperties.refresh().expireTime();
        String token = jwtProvider.generateToken(
                subject,
                Map.of(CLIENT_CLAIM_KEY, client.name()),
                expireTime
        );

        refreshTokenStore.save(user.getId(), client, token, expireTime);

        return new RefreshToken(token);
    }

    public boolean isValidRefreshToken(String requestedRefreshToken){
        long userId = parseUserId(requestedRefreshToken);

        return parseClient(requestedRefreshToken)
                .flatMap(client -> refreshTokenStore.find(userId, client))
                .map(foundRefreshToken -> Objects.equals(foundRefreshToken, requestedRefreshToken))
                .orElse(false);
    }

    private long parseUserId(String token) {
        return Long.parseLong(jwtProvider.parseSubject(token).value());
    }

    private Optional<LoginClient> parseClient(String token) {
        return LoginClient.fromClaim(jwtProvider.parseClaim(token, CLIENT_CLAIM_KEY));
    }

    public void deleteRefreshToken(String refreshToken) {
        if (!isValidRefreshToken(refreshToken)) {
            return;
        }

        long userId = parseUserId(refreshToken);
        parseClient(refreshToken)
                .ifPresent(client -> refreshTokenStore.delete(userId, client));
    }

    public void deleteAllRefreshTokens(long userId) {
        refreshTokenStore.deleteAll(userId);
    }

    public void validateToken(String token){
        jwtProvider.validateToken(token);
    }

    public Authentication getAuthUser(User user){
        return jwtProvider.getAuthentication(user);
    }

    public User parseUser(String token) {
        Subject subject = jwtProvider.parseSubject(token);
        long siteUserId = Long.parseLong(subject.value());
        return userRepository.findById(siteUserId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));
    }

    private Subject toSubject(User user) {
        return new Subject(user.getId().toString());
    }

}
