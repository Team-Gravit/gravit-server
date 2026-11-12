package gravit.code.season.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.season.calendar.SeasonCalendar;
import gravit.code.season.calendar.dto.SeasonDto;
import gravit.code.season.domain.Season;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

import static gravit.code.global.exception.domain.CustomErrorCode.BATCH_ACTIVE_SEASON_CONFLICT;

@Service
@RequiredArgsConstructor
@Slf4j
public class SeasonService {

    private final SeasonRepository seasonRepository;

    private final SeasonCalendar calendar;

    @Transactional
    public Season getOrCreateActiveSeason(){

        Optional<Season> activeSeason  = seasonRepository.findByStatus(SeasonStatus.ACTIVE);
        if(activeSeason.isPresent()) return activeSeason.get();

        Optional<Season> prepSeason = seasonRepository.findByStatus(SeasonStatus.PREP);
        if(prepSeason.isPresent()) return prepSeason.get();

        Optional<Season> finalizingSeason = seasonRepository.findByStatus(SeasonStatus.FINALIZING);
        if(finalizingSeason.isPresent()){
            SeasonDto next = calendar.nextFromEndsAt(finalizingSeason.get().getEndsAt());
            log.info("next season start time = {}", next.startsAt());
            log.info("next season end time = {}", next.endsAt());

            return seasonRepository.findBySeasonKey(next.seasonKey()).orElseGet(()->{
                try{
                    return seasonRepository.save(Season.prep(next.seasonKey(), next.startsAt(), next.endsAt()));
                }catch (DataIntegrityViolationException e){
                    return seasonRepository.findBySeasonKey(next.seasonKey()).orElseThrow(()-> new RestApiException(BATCH_ACTIVE_SEASON_CONFLICT));
                }
            });
        }

        SeasonDto current = calendar.currentSeason();

        return seasonRepository.findBySeasonKey(current.seasonKey()).orElseGet(()->{
            try{
                return seasonRepository.save(Season.active(current.seasonKey(), current.startsAt(), current.endsAt()));
            }catch (DataIntegrityViolationException e){
                return seasonRepository.findBySeasonKey(current.seasonKey()).orElseThrow(()-> new RestApiException(BATCH_ACTIVE_SEASON_CONFLICT));
            }
        });
    }

    @Transactional(readOnly = true)
    public Optional<LocalDateTime> getActiveSeasonEndsAt() {
        return seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .map(Season::getEndsAt);
    }

    @Transactional(readOnly = true)
    public Optional<LocalDateTime> getActiveSeasonStartsAt() {
        return seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .map(Season::getStartsAt);
    }
}
