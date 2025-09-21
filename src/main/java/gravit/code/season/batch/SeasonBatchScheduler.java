package gravit.code.season.batch;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class SeasonBatchScheduler {

    private final SeasonBatchService seasonBatchService;

    @Scheduled(
            cron = "${scheduler.season.rollover-cron:0 0 0 * * MON}",
            zone = "Asia/Seoul"
    )
    public void tryWeeklyRollover(){
        try{
            seasonBatchService.finalizeAndRolloverWeekly();
            log.info("Season Rollover 실행");
        }catch (RestApiException e){
            if(e.getErrorCode() == CustomErrorCode.ACTIVE_SEASON_NOT_FOUND){
                log.error("시즌 변경 작업 도중 ACTIVE 인 시즌이 존재하지 않아 예외 발생");
                return;
            }
        }
    }
}
