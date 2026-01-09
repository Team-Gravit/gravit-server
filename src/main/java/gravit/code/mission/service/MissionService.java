package gravit.code.mission.service;

import gravit.code.global.event.badge.MissionCompletedEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.lesson.service.LessonSubmissionQueryService;
import gravit.code.mission.domain.Mission;
import gravit.code.mission.domain.MissionRepository;
import gravit.code.mission.domain.MissionType;
import gravit.code.mission.domain.RandomMissionGenerator;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.response.MissionSummary;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * TODO 리팩토링 필요
 */
@Service
@RequiredArgsConstructor
public class MissionService {

    private final LessonSubmissionQueryService lessonSubmissionQueryService;

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

    public MissionSummary getMissionSummary(long userId){
        return missionRepository.findMissionSummaryByUserId(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));
    }

    @Transactional
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

        int tryCount = lessonSubmissionQueryService.getLessonSubmissionCount(userId,lessonId);

        if(tryCount > 1)
            return;

        // 미션 타입에 맞게 진행도 업데이트
        if (missionType.name().startsWith("COMPLETE_LESSON")) {
            mission.updateCompleteLessonProgress();
        } else if (missionType.name().startsWith("PERFECT_LESSON") && accuracy == 100) {
            mission.updatePerfectLessonProgress();
        } else if (missionType.name().startsWith("LEARNING_MINUTES")) {
            mission.updateLearningMinutesProgress(learningTime);
        }

        // 진행률 체크 후 미션 완료 상태 업데이트
        mission.checkAndUpdateCompletionStatus();

        // 미션을 완료했다면, 경험치 지급
        if (mission.isCompleted()){
            awardMissionXp(userId, mission.getMissionType().getAwardXp());
            publisher.publishEvent(new MissionCompletedEvent(userId));
        }
    }

    @Transactional
    public void handleFollowMission(FollowMissionEvent followMissionDto) {
        Mission mission = missionRepository.findByUserId(followMissionDto.userId())
                .orElseThrow(() -> new RestApiException(CustomErrorCode.MISSION_NOT_FOUND));

        if (mission.isCompleted()
                || !mission.getMissionType().name().equals("FOLLOW_NEW_FRIEND"))
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
