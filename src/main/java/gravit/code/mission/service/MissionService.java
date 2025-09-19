package gravit.code.mission.service;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.MissionCompletedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionRepository;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.dto.common.CreateMissionEvent;
import gravit.code.mission.dto.common.FollowMissionEvent;
import gravit.code.mission.dto.common.LessonMissionEvent;
import gravit.code.mission.util.MissionUtil;
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
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MissionService {

    private final MissionRepository missionRepository;
    private final LessonProgressRepository lessonProgressRepository;
    private final UserRepository userRepository;
    private final ApplicationEventPublisher publisher;

    @Retryable(
            retryFor = {ObjectOptimisticLockingFailureException.class},
            maxAttempts = 10,
            backoff = @Backoff(
                    delay = 100,
                    random = true
            )
    )
    public void handleLessonMission(LessonMissionEvent lessonMissionDto){
        Mission mission = missionRepository.findByUserId(lessonMissionDto.userId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));

        // 이미 미션을 완료했다면 처리 종료
        if(mission.getIsCompleted())
            return;

        MissionType missionType = mission.getMissionType();

        boolean isFirstAttempt = checkFirstAttemptLesson(lessonMissionDto.userId(), lessonMissionDto.lessonId());

        // 미션 타입에 맞게 진행도 업데이트
        if(missionType.name().startsWith("COMPLETE_LESSON") && isFirstAttempt){
            mission.updateCompleteLessonProgress();
        }else if(missionType.name().startsWith("PERFECT_LESSONS") && lessonMissionDto.accuracy() == 100 && isFirstAttempt){
            mission.updatePerfectLessonProgress();
        }else{
            mission.updateLearningMinutesProgress(lessonMissionDto.learningTime());
        }

        // 진행률 체크 후 미션 완료 상태 업데이트
        mission.checkAndUpdateCompletionStatus();

        // 미션을 완료했다면, 경험치 지급
        if(mission.getIsCompleted()){
            awardMissionXp(lessonMissionDto.userId(), mission.getMissionType().getAwardXp());
            publisher.publishEvent(new MissionCompletedEvent(lessonMissionDto.userId()));
        }
    }

    public void handleFollowMission(FollowMissionEvent followMissionDto){
        Mission mission = missionRepository.findByUserId(followMissionDto.userId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));

        if(mission.getIsCompleted())
            return;

        /**
         * TODO 미션을 위해 팔로잉을 악용하는 케이스 방지
         *
         * 1) A가 팔로우 미션을 받은 상황, A는 이미 B를 팔로우중
         * 2) A가 미션을 완료하기 위해 B 팔로우 취소하고 다시 팔로우
         * 3) 현재 로직상에서는 이를 막을 방법이 없음
         *
         * 사용자 유치를 위해 팔로우 미션에 가장 큰 xp를 걸었는데, 악용되면 서비스적으로 좋지 않을 것이라 판단
         */

        mission.updateFollowProgress();

        awardMissionXp(followMissionDto.userId(), mission.getMissionType().getAwardXp());
    }

    public void createMission(CreateMissionEvent createMissionDto){
        Mission mission = Mission.builder()
                .missionType(MissionUtil.getRandomMissionType())
                .userId(createMissionDto.userId())
                .build();

        missionRepository.save(mission);
    }

    @Transactional
    public void reassignMission(){
        int size = 10;
        int offset = 0;

        while(true){
            Pageable pageable = PageRequest.of(offset, size);
            List<Mission> missions = missionRepository.findAll(pageable);

            if(missions.isEmpty())
                break;

            for(Mission mission : missions){
                mission.reassignMission();
            }

            offset++;
        }
    }

    private void awardMissionXp(Long userId, Integer awardXp){
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        user.getLevel().updateXp(awardXp);
        userRepository.save(user);
    }

    private boolean checkFirstAttemptLesson(Long userId, Long lessonId){
        LessonProgress lessonProgress = lessonProgressRepository.findByLessonIdAndUserId(userId, lessonId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.LESSON_PROGRESS_NOT_FOUND));

        return lessonProgress.getAttemptCount() == 1;
    }
}
