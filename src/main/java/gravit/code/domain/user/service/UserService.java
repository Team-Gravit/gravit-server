package gravit.code.domain.user.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.domain.user.dto.request.OnboardingRequest;
import gravit.code.domain.user.dto.response.UserLevelResponse;
import gravit.code.domain.user.dto.response.UserMainPageInfo;
import gravit.code.domain.user.dto.response.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public UserResponse findById(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(RuntimeException::new);
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse onboarding(Long userId, OnboardingRequest request) {
        User user = userRepository.findById(userId).orElseThrow(RuntimeException::new);

        if(user.isOnboarded()){
            throw new RuntimeException("이미 추가 정보 입력이 완료된 사용자 입니다.");
        }

        if(userRepository.existsByNickname(request.nickname())){
            throw new RuntimeException("이미 사용 중인 닉네임 입니다.");
        }

        user.onboard(request.nickname(), request.avatarId());
        user.checkOnboarded();
        return UserResponse.from(user);
    }

    public UserLevelResponse updateUserLevel(Long userId){
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.updateXp(20);

        return UserLevelResponse.create(user.getLevel(), user.getXp());
    }

    public UserMainPageInfo getUserMainPageInfo(Long userId){
        return userRepository.findUserMainPageInfoByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
    }
}
