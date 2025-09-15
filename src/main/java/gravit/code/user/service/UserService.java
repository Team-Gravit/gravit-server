package gravit.code.user.service;

import gravit.code.global.event.OnboardingUserLeagueEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.event.CreateLearningEvent;
import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.mission.dto.common.CreateMissionEvent;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.dto.response.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

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

        user.onboard(request.nickname(), request.profilePhotoNumber());

        publisher.publishEvent(new CreateLearningEvent(user.getId()));
        publisher.publishEvent(new OnboardingUserLeagueEvent(user.getId()));
        publisher.publishEvent(new CreateMissionEvent(user.getId()));

        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse updateUserProfile(Long userId, UserProfileUpdateRequest request){
        User user = userRepository.findById(userId).orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.updateProfile(request.nickname(), request.profilePhotoNumber());

        return UserResponse.from(user);
    }

    @Transactional(readOnly = true)
    public MyPageResponse getMyPage(Long userId) {
        return userRepository.findMyPageByUserId(userId).orElseThrow(()-> new RestApiException(CustomErrorCode.USER_PAGE_NOT_FOUND));
    }


    @Transactional
    public UserLevelResponse updateUserLevelAndXp(Long userId){
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.updateXp(20);

        return UserLevelResponse.create(user.getLevel(), user.getXp());
    }

    @Retryable(
            retryFor = {ObjectOptimisticLockingFailureException.class},
            maxAttempts = 10,
            backoff = @Backoff(
                    delay = 100,
                    random = true
            )
    )
    @Transactional(readOnly = true)
    public MainPageResponse getMainPage(Long userId) {
        return userRepository.findMainPageByUserId(userId);
    }
}
