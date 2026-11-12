package gravit.code.user.batch;

import gravit.code.user.facade.UserDeletionFacade;
import gravit.code.user.infrastructure.RedisUserCleanManager;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserCleanScheduler {

    private final UserDeletionFacade userDeletionFacade;

    private final RedisUserCleanManager cleanManager;

    @Scheduled(
            cron = "0 0 * * * *",
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
        int skipped = 0;
        int failed = 0;

        for(Long userId : dueIds){
            try{
                boolean cleaned = userDeletionFacade.cleanUserDeletion(userId);
                cleanManager.removeUserKey(userId);

                if (cleaned) {
                    processed++;
                } else {
                    skipped++;
                }
            }catch (Exception e){
                failed++;
                log.warn("[clean] 유저 Clean Deletion 도중 에러 발생. userId : {}, msg : {}", userId,e.getMessage());
            }
        }

        log.info("[clean] 유저 Clean Deletion Batch 작업 종료. processed : {}, skipped : {}, failed : {}", processed, skipped, failed);
    }
}
