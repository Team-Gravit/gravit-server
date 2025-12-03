package gravit.code.mission.listener;

import gravit.code.global.event.OnboardingCompletedEvent;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.dto.event.LessonMissionEvent;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Log4j2
@Component
@RequiredArgsConstructor
public class MissionEventListener {

    private final MissionService missionService;

    @Async("missionAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleCompleteLessonMission(LessonMissionEvent lessonMissionDto){
        try{
            missionService.handleLessonMission(lessonMissionDto);
        }catch(Exception e){
            log.error("Exception occurred while handling complete lesson mission event with {}", e.getMessage());
        }
    }

    @Async("missionAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleFollowMission(FollowMissionEvent followMissionDto){
        try{
            missionService.handleFollowMission(followMissionDto);
        }catch(Exception e){
            log.error("Exception occurred while handling follow mission event with {}", e.getMessage());
        }
    }

    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void createMission(OnboardingCompletedEvent event){
        try{
            missionService.createMission(event.userId());
        }catch(Exception e){
            log.error("Exception occurred while creating mission for new User with {}", e.getMessage());
        }
    }
}
