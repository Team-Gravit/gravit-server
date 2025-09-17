package gravit.code.auth.oauth.processor;

import gravit.code.auth.jwt.JwtProvider;
import gravit.code.auth.oauth.bootstrap.AdminRoleDecider;
import gravit.code.auth.oauth.dto.LoginResponse;
import gravit.code.auth.oauth.dto.OAuthUserInfo;
import gravit.code.auth.util.HandleGenerator;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthLoginProcessor {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider;
    private final HandleGenerator handleGenerator;
    private final AdminRoleDecider adminRoleDecider;

    @Transactional
    public LoginResponse process(OAuthUserInfo oAuthUserInfo) {
        User user = findOrCreateUser(oAuthUserInfo);
        log.info("find or create user : {}", user);
        boolean isOnboarded = user.isOnboarded();

        String accessToken = jwtProvider.createAccessToken(user.getId());

        return new LoginResponse(accessToken, isOnboarded);
    }

    private User findOrCreateUser(OAuthUserInfo oAuthUserInfo) {
        String providerId = oAuthUserInfo.getProvider() + " " + oAuthUserInfo.getProviderId();

        return userRepository.findByProviderId(providerId)
                .map(u -> promoteIfAdminWhitelist(u, oAuthUserInfo)) // 유저가 존재하고, admin 승격 가능성 확인
                .orElseGet(()-> registerNewUser(oAuthUserInfo, providerId)); // 유저가 존재하지 않으면 생성
    }

    private User registerNewUser(OAuthUserInfo oAuthUserInfo, String providerId) {
        log.info("첫 로그인, 회원가입 시작");
        String handle = handleGenerator.generateUniqueHandle();
        Role initialRole = adminRoleDecider.initRole(oAuthUserInfo.getEmail());

        User user = User.create(
                oAuthUserInfo.getEmail(),
                providerId,
                oAuthUserInfo.getName(),
                handle,
                1,
                initialRole
        );

        userRepository.save(user);
        log.info("회원 가입 완료(초기 롤: {})", initialRole);
        return user;
    }

    private User promoteIfAdminWhitelist(User user, OAuthUserInfo oAuthUserInfo) {
        log.info("oAuthUserInfo.getEmail() : {}", oAuthUserInfo.getEmail());
        if (user.getRole() != Role.ADMIN &&
                adminRoleDecider.shouldPromoteToAdmin(oAuthUserInfo.getEmail())) {
            user.changeRole(Role.ADMIN);
            log.info("화이트리스트 일치: USER → ADMIN 승격 (userId={})", user.getId());
        }
        return user;
    }

}