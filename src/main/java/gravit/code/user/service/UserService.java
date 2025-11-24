package gravit.code.user.service;

import gravit.code.global.event.OnboardingUserLeagueEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.event.CreateLearningEvent;
import gravit.code.learning.dto.response.LearningDetail;
import gravit.code.learning.service.LearningService;
import gravit.code.user.dto.response.MainPageResponse;
import gravit.code.mission.dto.event.CreateMissionEvent;
import gravit.code.mission.dto.response.MissionDetail;
import gravit.code.mission.dto.response.MissionSummary;
import gravit.code.mission.service.MissionService;
import gravit.code.user.domain.HandleGenerator;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.domain.UserRepository;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserLevelDetail;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.dto.response.UserResponse;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    private final MissionService missionService;
    private final UserLeagueService userLeagueService;

    private final ApplicationEventPublisher publisher;
    private final HandleGenerator handleGenerator;
    private final LearningService learningService;

    @Transactional(readOnly = true)
    public UserResponse findById(long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse onboarding(
            long userId,
            OnboardingRequest request
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.onboard(request.nickname(), request.profilePhotoNumber());

        publisher.publishEvent(new CreateLearningEvent(user.getId()));
        publisher.publishEvent(new OnboardingUserLeagueEvent(user.getId()));
        publisher.publishEvent(new CreateMissionEvent(user.getId()));

        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse updateUserProfile(
            long userId,
            UserProfileUpdateRequest request
    ){
        User user = userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.updateProfile(request.nickname(), request.profilePhotoNumber());

        return UserResponse.from(user);
    }

    @Transactional(readOnly = true)
    public MyPageResponse getMyPage(long userId) {
        return userRepository.findMyPageByUserId(userId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.USER_PAGE_NOT_FOUND));
    }
    
    @Transactional
    public UserLevelResponse updateUserLevelAndXp(
            long userId,
            int xp,
            int accuracy
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.getLevel().updateXp((int) Math.round(xp * accuracy * 0.01));

        return UserLevelResponse.create(user.getLevel().getLevel(), user.getLevel().getXp());
    }

    @Transactional(readOnly = true)
    public MainPageResponse getMainPage(long userId) {
        String nickname = userRepository.findNicknameById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        UserLevelDetail userLevelDetail = getUserLevelDetail(userId);

        String leagueName = userLeagueService.getUserLeagueName(userId);

        MissionSummary missionSummary = missionService.getMissionSummary(userId);

        MissionDetail missionDetail = MissionDetail.from(missionSummary);

        LearningDetail learningDetail = learningService.getUserLearningDetail(userId);

        return MainPageResponse.of(nickname, leagueName, userLevelDetail, missionDetail, learningDetail);
    }

    @Transactional
    public void restoreUser(String providerId){
        User user = userRepository.findByProviderId(providerId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
        String newHandle = handleGenerator.generateUniqueHandle();
        user.restoreUser(newHandle);
    }

    private UserLevelDetail getUserLevelDetail(long userId){
        UserLevel userLevel = userRepository.findUserLevelById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        return UserLevelDetail.of(userLevel, userLevel.calculateLevelRate(userLevel.getXp()));
    }
}
