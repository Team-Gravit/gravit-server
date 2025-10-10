package gravit.code.user.batch;

import gravit.code.user.infrastructure.RedisUserCleanManager;
import gravit.code.user.service.UserDeletionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserCleanScheduler {

    private final UserDeletionService userDeletionService;
    private final RedisUserCleanManager cleanManager;

    @Scheduled(
            cron = "${scheduler.season.rollover-cron:0 0 0 * * MON}",
            zone = "Asia/Seoul"
    )
    public void cleanUsers(){
        List<Long> dueIds = cleanManager.allDueUserIds();
        log.info("Cleaning users due ids: {}", dueIds);

        if(dueIds.isEmpty()){
            log.info("Clean 삭제 할 유저가 존재하지 않습니다.");
            return;
        }

        int processed = 0;
        int failed = 0;

        for(Long userId : dueIds){
            try{
                userDeletionService.cleanUserDeletion(userId);
                cleanManager.removeUserKey(userId);
                processed++;
            }catch (Exception e){
                failed++;
                log.warn("[clean] 유저 Clean Deletion 도중 에러 발생. userId : {}, msg : {}", userId,e.getMessage());
            }
        }

        log.info("[clean] 유저 Clean Deletion Batch 작업 종료. processed : {}, failed : {}", processed, failed);
    }
}
