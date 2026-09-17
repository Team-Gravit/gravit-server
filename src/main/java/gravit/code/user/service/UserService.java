package gravit.code.user.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.dto.request.LessonSubmissionSaveRequest;
import gravit.code.user.domain.User;
import gravit.code.user.dto.event.LevelUpFeedEvent;
import gravit.code.user.dto.event.OnboardingCompletedEvent;
import gravit.code.user.dto.internal.UserSummaryDto;
import gravit.code.user.dto.request.OnboardingRequest;
import gravit.code.user.dto.request.UserProfileUpdateRequest;
import gravit.code.user.dto.response.MyPageResponse;
import gravit.code.user.dto.response.UserLevelResponse;
import gravit.code.user.dto.response.UserResponse;
import gravit.code.user.repository.UserRepository;
import gravit.code.user.support.RandomHandleGenerator;
import gravit.code.userLeague.dto.event.LeagueRankChangedEvent;
import gravit.code.userLeague.repository.UserLeagueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_PAGE_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class UserService {

    private static final int POINT_PER_LESSON = 20;

    private final UserRepository userRepository;
    private final UserLeagueRepository userLeagueRepository;

    private final RandomHandleGenerator handleGenerator;

    private final ApplicationEventPublisher publisher;

    @Transactional(readOnly = true)
    public UserResponse findById(long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(USER_NOT_FOUND));
        return UserResponse.from(user);
    }

    @Transactional
    public UserResponse onboard(
            long userId,
            OnboardingRequest request
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(USER_NOT_FOUND));

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
                .orElseThrow(()-> new RestApiException(USER_NOT_FOUND));

        user.updateProfile(request.nickname(), request.profilePhotoNumber());

        return UserResponse.from(user);
    }

    @Transactional(readOnly = true)
    public MyPageResponse getMyPage(long userId) {
        return userRepository.findMyPageByUserId(userId)
                .orElseThrow(()-> new RestApiException(USER_PAGE_NOT_FOUND));
    }

    @Transactional
    public void restoreUser(String providerId){
        User user = userRepository.findByProviderId(providerId)
                .orElseThrow(()-> new RestApiException(USER_NOT_FOUND));
        String newHandle = handleGenerator.generateUniqueHandle();
        user.restoreUser(newHandle);

        userLeagueRepository.findByUserId(user.getId()).ifPresent(userLeague ->
                publisher.publishEvent(LeagueRankChangedEvent.joined(
                        user.getId(),
                        userLeague.getSeason().getId(),
                        userLeague.getLeague().getId(),
                        userLeague.getLp()
                )));
    }

    @Transactional
    public boolean updateUserLevelByLessonSubmission(
            long userId,
            LessonSubmissionSaveRequest request,
            boolean isFirstTry
    ){
        boolean isLevelUp;

        if(isFirstTry){
            isLevelUp = updateUserLevelAndXp(userId, POINT_PER_LESSON, request.accuracy());
        }else{
            isLevelUp = updateUserLevelAndXp(userId, 0, request.accuracy());
        }
        return isLevelUp;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void addXp(
            long userId,
            int xp
    ) {
        applyXp(userId, xp);
    }

    @Transactional(readOnly = true)
    public UserLevelResponse getUserLevel(long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        return UserLevelResponse.create(user.getLevel().getLevel(), user.getLevel().getXp());
    }

    @Transactional(readOnly = true)
    public User getUser(long userId) {
        return userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(USER_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public Map<Long, UserSummaryDto> getUserSummaries(Set<Long> userIds) {
        if (userIds.isEmpty()) {
            return Collections.emptyMap();
        }

        return userRepository.findSummariesByIds(userIds).stream()
                .collect(Collectors.toMap(UserSummaryDto::id, Function.identity()));
    }

    private boolean updateUserLevelAndXp(
            long userId,
            int xp,
            int accuracy
    ) {
        return applyXp(userId, (int) Math.round(xp * accuracy * 0.01));
    }

    private boolean applyXp(
            long userId,
            int earnedXp
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        int oldLevel = user.getLevel().getLevel();
        user.getLevel().updateXp(earnedXp);
        int newLevel = user.getLevel().getLevel();

        boolean isLevelUp = newLevel > oldLevel;
        if (isLevelUp) {
            publisher.publishEvent(new LevelUpFeedEvent(userId, newLevel));
        }

        return isLevelUp;
    }
}
