package gravit.code.season.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.season.calendar.SeasonCalendar;
import gravit.code.season.calendar.dto.SeasonDto;
import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class SeasonService {

    private final SeasonRepository seasonRepository;
    private final SeasonCalendar calendar;

    @Transactional
    public Season getOrCreateActiveSeason(){

        // ACTIVE 인 시즌이 있다면 가져오기
        Optional<Season> activeSeason  = seasonRepository.findByStatus(SeasonStatus.ACTIVE);
        if(activeSeason.isPresent()) return activeSeason.get();

        // ACTIVE 인 시즌이 없다면 PREP 시즌 찾아서 리턴(추후 해당 시즌 시작시, ACTIVE 로 수정)
        Optional<Season> prepSeason = seasonRepository.findByStatus(SeasonStatus.PREP);
        if(prepSeason.isPresent()) return prepSeason.get();

        // FINALIZING 이 존재 -> 배치(해당 시즌 마무리-> history 저장 및 UserLeague 초기화) 진행중이라는 뜻
        // 새 시즌은 PREP 으로 만들기 (FINALIZING 시즌의 실제 endsAt 기준으로 다음 시즌 계산)
        Optional<Season> finalizingSeason = seasonRepository.findByStatus(SeasonStatus.FINALIZING);
        if(finalizingSeason.isPresent()){
            SeasonDto next = calendar.nextFromEndsAt(finalizingSeason.get().getEndsAt());
            log.info("next season start time = {}", next.startsAt());
            log.info("next season end time = {}", next.endsAt());


            return seasonRepository.findBySeasonKey(next.seasonKey()).orElseGet(()->{
                try{
                    return seasonRepository.save(Season.prep(next.seasonKey(), next.startsAt(), next.endsAt()));
                }catch (DataIntegrityViolationException e){
                    return seasonRepository.findBySeasonKey(next.seasonKey()).orElseThrow(()-> new RestApiException(CustomErrorCode.BATCH_ACTIVE_SEASON_CONFLICT));
                }
            });
        }

        // 정말 아무것도 없는 초기 부트스트랩 시 에만 ACTIVE 생성
        SeasonDto current = calendar.currentSeason();

        return seasonRepository.findBySeasonKey(current.seasonKey()).orElseGet(()->{
            try{
                return seasonRepository.save(Season.active(current.seasonKey(), current.startsAt(), current.endsAt()));
            }catch (DataIntegrityViolationException e){
                return seasonRepository.findBySeasonKey(current.seasonKey()).orElseThrow(()-> new RestApiException(CustomErrorCode.BATCH_ACTIVE_SEASON_CONFLICT));
            }
        });
    }

    // 시즌 종료 임박 알림 발송 시점 판정을 위해 현재 ACTIVE 시즌의 종료 시각을 조회한다
    @Transactional(readOnly = true)
    public Optional<LocalDateTime> getActiveSeasonEndsAt() {
        return seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .map(Season::getEndsAt);
    }
}
