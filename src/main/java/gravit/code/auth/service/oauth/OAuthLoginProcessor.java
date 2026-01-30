package gravit.code.auth.service.oauth;

import gravit.code.auth.domain.AccessToken;
import gravit.code.auth.domain.RefreshToken;
import gravit.code.auth.dto.oauth.OAuthUserInfo;
import gravit.code.auth.dto.response.LoginResponse;
import gravit.code.auth.policy.AdminPromotionPolicy;
import gravit.code.auth.service.AuthTokenProvider;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.exception.AccountSoftDeletedException;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.support.RandomHandleGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuthLoginProcessor {

    private final UserRepository userRepository;
    private final AuthTokenProvider authTokenProvider;
    private final RandomHandleGenerator handleGenerator;
    private final AdminPromotionPolicy adminPromotionPolicy;

    @Transactional
    public LoginResponse process(OAuthUserInfo oAuthUserInfo) {
        User user = findOrCreateUser(oAuthUserInfo);
        boolean isOnboarded = user.isOnboarded();

        AccessToken accessToken = authTokenProvider.generateAccessToken(user);
        RefreshToken refreshToken = authTokenProvider.generateRefreshToken(user);

        return LoginResponse.of(accessToken, refreshToken, isOnboarded);
    }

    private User findOrCreateUser(OAuthUserInfo oAuthUserInfo) {
        String providerId = oAuthUserInfo.getProvider() + "_" + oAuthUserInfo.getProviderId();

        return userRepository.findByProviderId(providerId)
                .map(u -> {  // 유저가 존재하면 삭제 여부 확인 후, admin 승격 가능성 확인
                    if(u.isDeleted()){
                        log.warn("[OAuthLoginProcessor] 삭제된 계정 로그인 시도. providerId: {}", providerId);
                        throw new AccountSoftDeletedException(u.getProviderId());
                    }

                    log.info("[OAuthLoginProcessor] 기존 유저 로그인. userId: {}, role: {}", u.getId(), u.getRole());
                    return promoteToAdminByWhitelist(u, oAuthUserInfo);
                })
                .orElseGet(()-> registerNewUser(oAuthUserInfo, providerId)); // 유저가 존재하지 않으면 생성
    }

    private User registerNewUser(
            OAuthUserInfo oAuthUserInfo,
            String providerId
    ) {
        log.info("[OAuthLoginProcessor] 신규 유저 회원가입 시작. email: {}, providerId: {}", oAuthUserInfo.getEmail(), providerId);
        String handle = handleGenerator.generateUniqueHandle();
        Role initialRole = adminPromotionPolicy.initRole(oAuthUserInfo.getEmail());

        User user = User.create(
                oAuthUserInfo.getEmail(),
                providerId,
                oAuthUserInfo.getName(),
                handle,
                1,
                initialRole
        );

        userRepository.save(user);
        log.info("[OAuthLoginProcessor] 신규 유저 회원가입 완료. userId: {}, handle: {}, role: {}", user.getId(), user.getHandle(), user.getRole());

        return user;
    }

    private User promoteToAdminByWhitelist(
            User user,
            OAuthUserInfo oAuthUserInfo
    ) {
        log.info("oAuthUserInfo.getEmail() : {}", oAuthUserInfo.getEmail());
        if (user.getRole() != Role.ADMIN && adminPromotionPolicy.shouldPromoteToAdmin(oAuthUserInfo.getEmail())) {
            user.changeRole(Role.ADMIN);
            log.info("화이트리스트 일치: USER → ADMIN 승격 (userId={})", user.getId());
        }
        return user;
    }

}
