package gravit.code.badge.listener;

import gravit.code.badge.dto.MissionCompleteDto;
import gravit.code.badge.dto.PlanetCompletionDto;
import gravit.code.badge.dto.QualifiedSolveCountDto;
import gravit.code.badge.service.BadgeGrantService;
import gravit.code.badge.service.ProjectionService;
import gravit.code.global.event.LessonCompletedEvent;
import gravit.code.global.event.badge.MissionCompletedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Slf4j
@Component
@RequiredArgsConstructor
@Async("badgeAsync")
public class BadgeEventListener {

    private final ProjectionService projectionService;
    private final BadgeGrantService badgeGrantService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleLessonCompleted(LessonCompletedEvent event){
        try{
            log.info("레슨 완료 뱃지 평가 시작");

            // 1. 행성 완료 뱃지
            PlanetCompletionDto planetDto = projectionService.recordPlanetCompletion(
                    event.userId(), event.chapterId()
            );
            if(planetDto != null){
                badgeGrantService.evaluatePlanet(
                        planetDto.userId(),
                        planetDto.planetName(),
                        planetDto.allPlanetsCompleted()
                );
            }

            // 2. 풀이 속도 뱃지
            QualifiedSolveCountDto qualifiedDto = projectionService.recordQualifiedSolveStat(
                    event.userId(), event.accuracy(), event.learningTime()
            );
            badgeGrantService.evaluateQualifiedSolvedCount(
                    qualifiedDto.userId(), qualifiedDto.qualifiedCount()
            );

            // 3. 연속 학습 뱃지 (조건부)
            if(event.beforeConsecutiveSolved() != event.afterConsecutiveSolved()){
                badgeGrantService.evaluateStreak(
                        event.userId(), event.afterConsecutiveSolved()
                );
            }

            log.info("레슨 완료 뱃지 평가 완료");
        }catch(Exception e){
            log.error("레슨 완료 뱃지 평가 에러: {}", e.getMessage());
        }
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
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
}
