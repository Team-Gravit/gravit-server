package gravit.code.badge.listener;

import gravit.code.badge.dto.MissionCompleteDto;
import gravit.code.badge.dto.PlanetCompletionDto;
import gravit.code.badge.dto.QualifiedSolveCountDto;
import gravit.code.badge.service.BadgeGrantService;
import gravit.code.badge.service.ProjectionService;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.ConsecutiveSolvedEvent;
import gravit.code.global.event.badge.MissionCompletedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Slf4j
@Component
@RequiredArgsConstructor
public class BadgeEventListener {

    private final ProjectionService projectionService;
    private final BadgeGrantService badgeGrantService;

    @Async("badgeAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handlePlanetCompleted(LessonCompletedEvent event){
        try{
            log.info("handlePlanetCompleted 이벤트 리슨");
            PlanetCompletionDto dto = projectionService.recordPlanetCompletion(
                    event.userId(), event.chapterId()
            );

            if(dto != null){
                badgeGrantService.evaluatePlanet(
                        dto.userId(), dto.planetName(), dto.allPlanetsCompleted()
                );
            }

        }catch(Exception e){
            log.error("handlePlanetCompleted 에러:  {}", e.getMessage());
        }
    }

    @Async("badgeAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleMissionCompleted(MissionCompletedEvent event){
        try{
            MissionCompleteDto dto = projectionService.recordMissionStat(
                    event.userId()
            );

            badgeGrantService.evaluateMissionCount(
                    dto.userId(), dto.missionCompleteCount()
            );

        }catch(Exception e){
            log.error("handleMissionCompleted 에러 : {}", e.getMessage());
        }
    }

    @Async("badgeAsync")
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleQualifiedSolved(LessonCompletedEvent event){
        try{
            QualifiedSolveCountDto dto = projectionService.recordQualifiedSolveStat(
                    event.userId(), event.accuracy(), event.learningTime()
            );

            badgeGrantService.evaluateQualifiedSolvedCount(
                    dto.userId(), dto.qualifiedCount()
            );
        }catch(Exception e){
            log.error("handleQualifiedSolve 리스너 에러: {}", e.getMessage());
        }
    }

    @Async("badgeAsync")
    @EventListener
    public void handleConsecutiveSolvedDays(ConsecutiveSolvedEvent event){
        try{
            log.info("handleConsecutiveSolvedDays 실행");
            badgeGrantService.evaluateStreak(
                    event.userId(), event.streakCount()
            );
        }catch(Exception e){
            log.error("handleStreak 리스너 에러: {}", e.getMessage());
        }
    }
}
