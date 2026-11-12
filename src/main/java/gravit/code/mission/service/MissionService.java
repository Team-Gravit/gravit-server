package gravit.code.mission.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionStatus;
import gravit.code.mission.domain.UserMission;
import gravit.code.mission.domain.WeightedMissionPicker;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.internal.AssignedMissionDto;
import gravit.code.mission.dto.response.MissionDetailResponse;
import gravit.code.mission.repository.MissionRepository;
import gravit.code.mission.repository.UserMissionRepository;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

import static gravit.code.global.exception.domain.CustomErrorCode.MISSION_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Slf4j
@Service
@RequiredArgsConstructor
public class MissionService {

    private final LessonSubmissionQueryService lessonSubmissionQueryService;

    private final MissionRepository missionRepository;
    private final UserMissionRepository userMissionRepository;
    private final UserRepository userRepository;

    private final WeightedMissionPicker weightedMissionPicker;

    private final Clock clock;

    @Transactional
    public MissionDetailResponse getMissionDetail(long userId) {
        LocalDate today = LocalDate.now(clock);

        AssignedMissionDto assigned = userMissionRepository.findAssignedMission(userId, today)
                .orElseGet(() -> {
                    assignToday(userId, today);
                    return findTodayMission(userId);
                });

        return MissionDetailResponse.of(assigned.mission(), assigned.userMission());
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleLessonMission(
            long userId,
            long lessonId,
            int learningTime,
            int accuracy
    ) {
        AssignedMissionDto assigned = findTodayMission(userId);
        UserMission userMission = assigned.userMission();
        Mission mission = assigned.mission();

        if (userMission.isCompleted())
            return;

        if (lessonSubmissionQueryService.getLessonSubmissionTryCount(userId, lessonId) > 1)
            return;

        int increment = mission.calculateLessonIncrement(accuracy, learningTime);
        if (increment == 0)
            return;

        userMission.addProgress(increment);

        completeIfAchieved(userMission, mission);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleFollowMission(FollowMissionEvent followMissionDto) {
        AssignedMissionDto assigned = findTodayMission(followMissionDto.userId());
        UserMission userMission = assigned.userMission();
        Mission mission = assigned.mission();

        if (userMission.isCompleted())
            return;

        int increment = mission.calculateFollowIncrement();
        if (increment == 0)
            return;

        userMission.addProgress(increment);

        completeIfAchieved(userMission, mission);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createMission(long userId) {
        assignToday(userId, LocalDate.now(clock));
    }

    @Transactional
    public long assignChunk(
            LocalDate assignedDate,
            long lastUserId,
            int chunkSize
    ) {
        List<Long> userIds = userRepository.findOnboardedIdsAfter(lastUserId, PageRequest.of(0, chunkSize));
        if (userIds.isEmpty())
            return lastUserId;

        Set<Long> alreadyAssignedUserIds = userMissionRepository.findAssignedUserIds(assignedDate, userIds);

        List<Mission> activeMissions = missionRepository.findAllByStatus(MissionStatus.ACTIVE);

        int insertedCount = 0;
        for (Long userId : userIds) {
            if (alreadyAssignedUserIds.contains(userId))
                continue;

            Mission picked = weightedMissionPicker.pick(activeMissions);
            insertedCount += userMissionRepository.insertIfAbsent(
                    userId,
                    picked.getId(),
                    assignedDate,
                    LocalDateTime.now(clock)
            );
        }

        long newLastUserId = userIds.get(userIds.size() - 1);
        log.info("미션 배정 청크 완료 - 조회 유저 수: {}, 신규 삽입 수: {}, 마지막 유저 id: {}",
                userIds.size(), insertedCount, newLastUserId);

        return newLastUserId;
    }

    private void assignToday(
            long userId,
            LocalDate assignedDate
    ) {
        if (userMissionRepository.existsByUserIdAndAssignedDate(userId, assignedDate))
            return;

        List<Mission> activeMissions = missionRepository.findAllByStatus(MissionStatus.ACTIVE);
        Mission picked = weightedMissionPicker.pick(activeMissions);

        userMissionRepository.insertIfAbsent(
                userId,
                picked.getId(),
                assignedDate,
                LocalDateTime.now(clock)
        );
    }

    private AssignedMissionDto findTodayMission(long userId) {
        return userMissionRepository.findAssignedMission(userId, LocalDate.now(clock))
                .orElseThrow(() -> new RestApiException(MISSION_NOT_FOUND));
    }

    private void completeIfAchieved(
            UserMission userMission,
            Mission mission
    ) {
        if (!mission.isAchieved(userMission.getProgressCount()))
            return;

        int completed = userMissionRepository.completeIfNotCompleted(
                userMission.getId(),
                LocalDateTime.now(clock)
        );
        if (completed == 0)
            return;

        awardMissionXp(userMission.getUserId(), mission.getAwardXp());
    }

    private void awardMissionXp(
            long userId,
            int awardXp
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        user.getLevel().updateXp(awardXp);
        userRepository.save(user);
    }
}
