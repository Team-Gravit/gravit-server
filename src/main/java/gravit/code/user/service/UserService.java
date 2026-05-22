package gravit.code.user.service;

import gravit.code.global.event.LevelUpFeedEvent;
import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.user.domain.User;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.dto.response.UserResponse;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.support.RandomHandleGenerator;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private static final int POINT_PER_LESSON = 20;

    private final UserRepository userRepository;

    private final ApplicationEventPublisher publisher;
    private final RandomHandleGenerator handleGenerator;

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

    @Transactional(readOnly = true)
    public User getUser(long userId) {
        return userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
    }

    private UserLevelResponse updateUserLevelAndXp(
            long userId,
            int xp,
            int accuracy
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        int oldLevel = user.getLevel().getLevel();
        user.getLevel().updateXp((int) Math.round(xp * accuracy * 0.01));
        int newLevel = user.getLevel().getLevel();

        if (newLevel > oldLevel) {
            publisher.publishEvent(new LevelUpFeedEvent(userId, newLevel));
        }

        return UserLevelResponse.create(newLevel, user.getLevel().getXp());
    }
}
