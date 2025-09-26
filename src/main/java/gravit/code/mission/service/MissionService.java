package gravit.code.mission.service;

import gravit.code.global.event.badge.MissionCompletedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionRepository;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.dto.MissionSummary;
import gravit.code.mission.dto.event.CreateMissionEvent;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.event.LessonMissionEvent;
import gravit.code.mission.domain.RandomMissionGenerator;
import gravit.code.progress.domain.LessonProgress;
import gravit.code.progress.domain.LessonProgressRepository;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
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

import java.util.List;

@Service
@RequiredArgsConstructor
public class MissionService {

    private final MissionRepository missionRepository;
    private final LessonProgressRepository lessonProgressRepository;
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
    public void handleLessonMission(LessonMissionEvent lessonMissionDto){
        Mission mission = missionRepository.findByUserId(lessonMissionDto.userId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));

        // 이미 미션을 완료했다면 처리 종료
        if(mission.isCompleted())
            return;

        MissionType missionType = mission.getMissionType();

        boolean isFirstAttempt = checkFirstAttemptLesson(lessonMissionDto.userId(), lessonMissionDto.lessonId());

        // 미션 타입에 맞게 진행도 업데이트
        if (missionType.name().startsWith("COMPLETE_LESSON") && isFirstAttempt) {
            mission.updateCompleteLessonProgress();
        } else if (missionType.name().startsWith("PERFECT_LESSONS") && lessonMissionDto.accuracy() == 100 && isFirstAttempt) {
            mission.updatePerfectLessonProgress();
        } else {
            mission.updateLearningMinutesProgress(lessonMissionDto.learningTime());
        }

        // 진행률 체크 후 미션 완료 상태 업데이트
        mission.checkAndUpdateCompletionStatus();

        // 미션을 완료했다면, 경험치 지급
        if (mission.isCompleted())
            awardMissionXp(lessonMissionDto.userId(), mission.getMissionType().getAwardXp());
        publisher.publishEvent(new MissionCompletedEvent(lessonMissionDto.userId()));
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleFollowMission(FollowMissionEvent followMissionDto) {
        Mission mission = missionRepository.findByUserId(followMissionDto.userId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));

        if (mission.isCompleted())
            return;

        mission.updateFollowProgress();

        awardMissionXp(followMissionDto.userId(), mission.getMissionType().getAwardXp());
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void createMission(CreateMissionEvent createMissionDto) {
        Mission mission = Mission.builder()
                .missionType(RandomMissionGenerator.getRandomMissionType())
                .userId(createMissionDto.userId())
                .build();

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

    private boolean checkFirstAttemptLesson(
            long userId,
            long lessonId
    ) {
        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(userId, lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_PROGRESS_NOT_FOUND));

        return lessonProgress.getAttemptCount() == 1;
    }

}
