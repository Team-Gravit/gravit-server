package gravit.code.mission.scheduler;

import gravit.code.mission.service.MissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MissionScheduler {

    private final MissionService missionService;

    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    public void reassignMission(){
        missionService.reassignMission();
    }
}