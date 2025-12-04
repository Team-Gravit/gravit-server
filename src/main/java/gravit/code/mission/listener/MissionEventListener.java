package gravit.code.mission.listener;

import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Log4j2
@Component
@RequiredArgsConstructor
public class MissionEventListener {

    private final MissionService missionService;

    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void handleCompleteLessonMission(LessonCompletedEvent event){
        try{
            missionService.handleLessonMission(
                    event.userId(),
                    event.lessonId(),
                    event.learningTime(),
                    event.accuracy()
            );
        }catch(Exception e){
            log.error("Exception occurred while handling complete lesson mission event with {}", e.getMessage());
        }
    }

    @TransactionalEventListener(phase = TransactionPhase.BEFORE_COMMIT)
    public void handleFollowMission(FollowMissionEvent followMissionDto){
        try{
            missionService.handleFollowMission(followMissionDto);
        }catch(Exception e){
            log.error("Exception occurred while handling follow mission event with {}", e.getMessage());
        }
    }
}
