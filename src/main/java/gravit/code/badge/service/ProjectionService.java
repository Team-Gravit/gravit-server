package gravit.code.badge.service;

import gravit.code.badge.domain.Planet;
import gravit.code.badge.domain.user.UserMissionStat;
import gravit.code.badge.domain.user.UserPlanetCompletion;
import gravit.code.badge.domain.user.UserQualifiedSolveStat;
import gravit.code.badge.dto.MissionCompleteDto;
import gravit.code.badge.dto.PlanetCompletionDto;
import gravit.code.badge.dto.QualifiedSolveCountDto;
import gravit.code.badge.infrastructure.user.UserMissionStatRepository;
import gravit.code.badge.infrastructure.user.UserPlanetCompletionRepository;
import gravit.code.badge.infrastructure.user.UserQualifiedSolveStatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ProjectionService {

    private final UserPlanetCompletionRepository planetCompletionRepository;
    private final UserMissionStatRepository userMissionStatRepository;
    private final UserQualifiedSolveStatRepository userQualifiedSolveStatRepository;

    @Transactional
    public PlanetCompletionDto recordPlanetCompletion(Long userId, Long chapterId, long beforeCount, long afterCount , long totalCounts) {
        Planet planet = Planet.getPlanetByChapterId(chapterId);

        if(beforeCount == afterCount || afterCount != totalCounts){
            return null;
        }

        if(planetCompletionRepository.existsByUserIdAndPlanet(userId, planet)) {
            return null;
        }

        planetCompletionRepository.save(UserPlanetCompletion.of(userId, planet));

        // 모든 챕터를 완료했는지 확인
        long userCompletionPlanetCount = planetCompletionRepository.countByUserId(userId);
        long totalPlanetCount = Planet.getTotalPlanets();
        boolean allPlanetsCompleted = userCompletionPlanetCount == totalPlanetCount;

        return new PlanetCompletionDto(
                userId, planet.name(), allPlanetsCompleted);
    }

    @Transactional
    public MissionCompleteDto recordMissionStat(long userId) {
        UserMissionStat userMissionStat = userMissionStatRepository.findByUserId(userId).orElseGet(
                () -> userMissionStatRepository.save(UserMissionStat.of(userId))
        );
        userMissionStat.plusCompletedCount();
        int missionCompletedCount = userMissionStat.getCompletedCount();
        return new MissionCompleteDto(userId, missionCompletedCount);
    }
    // 메서드명 수정하자

    @Transactional
    public  QualifiedSolveCountDto recordQualifiedSolveStat(long userId, int accurate, int seconds) {
        UserQualifiedSolveStat userSolveCountStat = userQualifiedSolveStatRepository.findByUserId(userId).orElseGet(
                () -> userQualifiedSolveStatRepository.save(UserQualifiedSolveStat.of(userId))
        );

        int qualifiedCount = userSolveCountStat.applySolve(accurate, seconds);
        return new QualifiedSolveCountDto(userId, qualifiedCount);
    }


}
