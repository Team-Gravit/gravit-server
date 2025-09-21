package gravit.code.user.service;

import gravit.code.global.event.OnboardingUserLeagueEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.event.CreateLearningEvent;
import gravit.code.mainPage.dto.MainPageSummary;
import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.mission.dto.MissionSummary;
import gravit.code.mission.dto.event.CreateMissionEvent;
import gravit.code.mission.service.MissionService;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.dto.response.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final MissionService missionService;

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
    public UserLevelResponse updateUserLevelAndXp(long userId, int xp, int accuracy) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.getLevel().updateXp((int) Math.round(xp * accuracy * 0.01));

        return UserLevelResponse.create(user.getLevel().getLevel(), user.getLevel().getXp());
    }

    @Transactional(readOnly = true)
    public MainPageResponse getMainPage(long userId) {
        MainPageSummary mainPageSummary =  userRepository.findMainPageByUserId(userId);
        MissionSummary missionSummary = missionService.getMissionSummary(userId);

        return MainPageResponse.create(mainPageSummary, missionSummary);
    }
}
