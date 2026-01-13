package gravit.code.user.service;

import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.dto.response.LearningDetail;
import gravit.code.learning.service.LearningService;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.mission.dto.response.MissionDetail;
import gravit.code.mission.dto.response.MissionSummary;
import gravit.code.mission.service.MissionService;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserLevel;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.*;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.support.RandomHandleGenerator;
import gravit.code.userLeague.service.UserLeagueService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private static final int POINT_PER_LESSON = 20;

    private final UserRepository userRepository;

    private final MissionService missionService;
    private final UserLeagueService userLeagueService;

    private final ApplicationEventPublisher publisher;
    private final RandomHandleGenerator handleGenerator;
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
        publisher.publishEvent(new OnboardingCompletedEvent(user.getId()));

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

    @Transactional
    public UserLevelResponse updateUserLevelByLessonSubmission(
            long userId,
            LessonSubmissionSaveRequest request,
            boolean isFirstTry
    ){
        UserLevelResponse userLevelResponse;

        if(isFirstTry){
            userLevelResponse = updateUserLevelAndXp(userId, POINT_PER_LESSON, request.accuracy());
        }else{
            userLevelResponse = updateUserLevelAndXp(userId, 0, request.accuracy());
        }
        return userLevelResponse;
    }

    private UserLevelResponse updateUserLevelAndXp(
            long userId,
            int xp,
            int accuracy
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.getLevel().updateXp((int) Math.round(xp * accuracy * 0.01));

        return UserLevelResponse.create(user.getLevel().getLevel(), user.getLevel().getXp());
    }
    
    private UserLevelDetail getUserLevelDetail(long userId){
        UserLevel userLevel = userRepository.findUserLevelById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        return UserLevelDetail.of(userLevel, userLevel.calculateLevelRate(userLevel.getXp()));
    }
}
