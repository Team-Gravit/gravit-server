package gravit.code.domain.user.service;

import gravit.code.domain.mainPage.dto.response.MainPageUserSummaryResponse;
import gravit.code.domain.recentLearning.service.RecentLearningService;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.domain.UserRepository;
import gravit.code.domain.user.dto.request.OnboardingRequest;
import gravit.code.domain.user.dto.response.MyPageResponse;
import gravit.code.domain.user.dto.response.UserLevelResponse;
import gravit.code.domain.user.dto.response.UserResponse;
import gravit.code.global.event.OnboardingUserLeagueEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final RecentLearningService recentLearningService;

    private final UserRepository userRepository;

    private final ApplicationEventPublisher publisher;

    @Transactional(readOnly = true)
    public UserResponse findById(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse onboarding(Long userId, OnboardingRequest request) {
        User user = userRepository.findById(userId).orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        if(user.isOnboarded()){
            throw new RestApiException(CustomErrorCode.ALREADY_ONBOARDING);
        }

        user.onboard(request.nickname(), request.profilePhotoNumber());
        user.checkOnboarded();

        recentLearningService.initRecentLearning(userId);

        publisher.publishEvent(new OnboardingUserLeagueEvent(user.getId()));

        return UserResponse.from(user);
    }

    @Transactional(readOnly = true)
    public MyPageResponse getMyPage(Long userId) {
        return userRepository.findMyPageByUserId(userId).orElseThrow(()-> new RestApiException(CustomErrorCode.USER_PAGE_NOT_FOUND));
    }

    public UserLevelResponse updateUserLevelAndXp(Long userId){
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.updateXp(20);

        return UserLevelResponse.create(user.getLevel(), user.getXp());
    }

    public MainPageUserSummaryResponse getMainPageUserSummary(Long userId){
        return userRepository.findUserMainPageSummaryByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
    }
}
