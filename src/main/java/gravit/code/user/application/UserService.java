package gravit.code.user.application;

import gravit.code.user.application.dto.request.OnboardingRequest;
import gravit.code.user.application.dto.response.UserResponse;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

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
}
