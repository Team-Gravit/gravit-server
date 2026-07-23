package gravit.code.mission.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionStatus;
import gravit.code.mission.domain.UserMission;
import gravit.code.mission.domain.WeightedMissionPicker;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.internal.AssignedMission;
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

        // 오늘자 배정이 없으면 조회 시점에 채운다 (자정 배정 누락 안전망)
        // 동시 요청이 먼저 넣었어도 ON CONFLICT가 조용히 넘기므로 재조회 한 번이면 충분하다
        AssignedMission assigned = userMissionRepository.findAssignedMission(userId, today)
                .orElseGet(() -> {
                    assignToday(userId, today);
                    return findTodayMission(userId);
                });

        return MissionDetailResponse.of(assigned.mission(), assigned.userMission());
    }

    @Transactional
    public void handleLessonMission(
            long userId,
            long lessonId,
            int learningTime,
            int accuracy
    ) {
        AssignedMission assigned = findTodayMission(userId);
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
        AssignedMission assigned = findTodayMission(followMissionDto.userId());
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

    // 온보딩 시 오늘자 UserMission 배정. MissionEventListener가 AFTER_COMMIT에서 호출하므로
    // 이름을 유지하고, 원본 트랜잭션에 참여해 배정이 커밋되지 않는 것을 막기 위해 REQUIRES_NEW로 격리한다
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createMission(long userId) {
        assignToday(userId, LocalDate.now(clock));
    }

    // 자정 스케줄러가 청크 단위로 호출한다. 한 번의 호출이 트랜잭션 하나다
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

    // 오늘자 UserMission을 삽입한다. 이미 있으면 아무 일도 일어나지 않는다
    private void assignToday(
            long userId,
            LocalDate assignedDate
    ) {
        List<Mission> activeMissions = missionRepository.findAllByStatus(MissionStatus.ACTIVE);
        Mission picked = weightedMissionPicker.pick(activeMissions);

        userMissionRepository.insertIfAbsent(
                userId,
                picked.getId(),
                assignedDate,
                LocalDateTime.now(clock)
        );
    }

    // 진행 갱신 경로에는 폴백을 걸지 않는다. 배정 없는 상태의 이벤트는 어차피 진행이 유실되므로 기존대로 예외를 올린다
    private AssignedMission findTodayMission(long userId) {
        return userMissionRepository.findAssignedMission(userId, LocalDate.now(clock))
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));
    }

    // 목표를 채웠고, 아직 아무도 완료 처리하지 않았을 때만 XP를 지급한다
    private void completeIfAchieved(
            UserMission userMission,
            Mission mission
    ) {
        if (!mission.isAchieved(userMission.getProgressCount()))
            return;

        // 조건부 UPDATE가 1을 반환한 트랜잭션만 XP를 지급한다. 동시 완료 시 두 번 나가지 않는다
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
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.getLevel().updateXp(awardXp);
        userRepository.save(user);
    }
}
