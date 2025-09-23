package gravit.code.auth.service;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.domain.Subject;
import gravit.code.auth.token.JwtProvider;
import gravit.code.auth.infrastructure.redis.RedisTokenStorage;
import gravit.code.auth.token.TokenStorage;
import gravit.code.auth.token.config.TokenProperties;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Objects;

@Component
@RequiredArgsConstructor
public class AuthTokenProvider {

    private static final String ROLE_CLAIM_KEY = "role";

    private final JwtProvider jwtProvider;
    private final TokenStorage tokenStorage;
    private final UserRepository userRepository;
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

    public RefreshToken generateRefreshToken(User user){
        Subject subject = toSubject(user);
        String token = jwtProvider.generateToken(
                subject,
                tokenProperties.refresh().expireTime()
        );
        RefreshToken refreshToken = new RefreshToken(token);
        return tokenStorage.saveToken(subject, refreshToken);
    }

    public boolean isValidRefreshToken(String requestedRefreshToken){
        Subject subject = jwtProvider.parseSubject(requestedRefreshToken);
        return tokenStorage.findToken(subject, RefreshToken.class)
                .map(foundRefreshToken -> Objects.equals(foundRefreshToken, requestedRefreshToken))
                .orElse(false);
    }

    public void validateToken(String token){
        jwtProvider.validateToken(token);
    }

    public Authentication getAuthUser(String token){
        User user = parseUser(token);
        return jwtProvider.getAuthentication(user);
    }

    public User parseUser(String token) {
        Subject subject = jwtProvider.parseSubject(token);
        long siteUserId = Long.parseLong(subject.value());
        return userRepository.findById(siteUserId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
    }

    private Subject toSubject(User user) {
        return new Subject(user.getId().toString());
    }

}
