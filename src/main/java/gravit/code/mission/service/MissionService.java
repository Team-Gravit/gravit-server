package gravit.code.mission.service;

import gravit.code.global.event.badge.MissionCompletedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.service.LessonSubmissionService;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionRepository;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.domain.RandomMissionGenerator;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.response.MissionSummary;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MissionService {

    private final LessonSubmissionService lessonSubmissionService;

    private final MissionRepository missionRepository;
    private final UserRepository userRepository;

    private final ApplicationEventPublisher publisher;

    @Transactional
    public void reassignMission(){
        int size = 10;
        int page = 0;

        while(true){
            Pageable pageable = PageRequest.of(page, size);
            List<Mission> missions = missionRepository.findAll(pageable);

            if(missions.isEmpty())
                break;

            for(Mission mission : missions){
                mission.reassignMission();
            }

            page++;
        }
    }

    @Retryable(
            retryFor = {ObjectOptimisticLockingFailureException.class},
            maxAttempts = 10,
            backoff = @Backoff(
                    delay = 100,
                    random = true
            )
    )
    public MissionSummary getMissionSummary(long userId){
        return missionRepository.findMissionSummaryByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));
    }

    @Retryable(
            retryFor = {ObjectOptimisticLockingFailureException.class},
            maxAttempts = 10,
            backoff = @Backoff(
                    delay = 100,
                    random = true
            )
    )
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleLessonMission(
            long userId,
            long lessonId,
            int learningTime,
            int accuracy
    ){
        Mission mission = missionRepository.findByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));

        // 이미 미션을 완료했다면 처리 종료
        if(mission.isCompleted())
            return;

        MissionType missionType = mission.getMissionType();

        boolean isFirstAttempt = lessonSubmissionService.checkUserSubmitted(userId, lessonId);

        // 미션 타입에 맞게 진행도 업데이트
        if (missionType.name().startsWith("COMPLETE_LESSON") && isFirstAttempt) {
            mission.updateCompleteLessonProgress();
        } else if (missionType.name().startsWith("PERFECT_LESSONS") && accuracy == 100 && isFirstAttempt) {
            mission.updatePerfectLessonProgress();
        } else {
            mission.updateLearningMinutesProgress(learningTime);
        }

        // 진행률 체크 후 미션 완료 상태 업데이트
        mission.checkAndUpdateCompletionStatus();

        // 미션을 완료했다면, 경험치 지급
        if (mission.isCompleted())
            awardMissionXp(userId, mission.getMissionType().getAwardXp());
        publisher.publishEvent(new MissionCompletedEvent(userId));
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleFollowMission(FollowMissionEvent followMissionDto) {
        Mission mission = missionRepository.findByUserId(followMissionDto.userId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));

        if (mission.isCompleted())
            return;

        mission.updateFollowProgress();

        mission.checkAndUpdateCompletionStatus();

        awardMissionXp(followMissionDto.userId(), mission.getMissionType().getAwardXp());
    }

    @Transactional
    public void createMission(long userId) {
        Mission mission = Mission.create(
                RandomMissionGenerator.getRandomMissionType(),
                userId
        );

        missionRepository.save(mission);
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
