package gravit.code.auth.oauth.processor;

import gravit.code.auth.jwt.JwtProvider;
import gravit.code.auth.oauth.dto.LoginResponse;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthLoginProcessor {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;

    public LoginResponse process(OAuthUserInfo oAuthUserInfo) {
        User user = findOrCreateUser(oAuthUserInfo);

        String accessToken = jwtProvider.createAccessToken(user.getId());

        return new LoginResponse(accessToken);
    }

    private User findOrCreateUser(OAuthUserInfo oAuthUserInfo) {
        String providerId = oAuthUserInfo.getProvider() + " " + oAuthUserInfo.getProviderId();
        log.info("providerId : {}", providerId);

        Optional<User> oldUser = userRepository.findByProviderId(providerId);
        User user;
        if (oldUser.isEmpty()) {
            log.info("첫 로그인, 회원가입 시작");
            user = User.create(oAuthUserInfo.getEmail(),
                    providerId,
                    oAuthUserInfo.getName(),
                    "test",
                    "test",
                    LocalDateTime.now());

            userRepository.save(user);
            log.info("회원 가입 완료");
            return user;
        }
        log.info("이미 가입된 유저입니다.");
        return oldUser.get();
    }


}
