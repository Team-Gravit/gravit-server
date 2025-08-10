package gravit.code.domain.season.service;

import gravit.code.domain.season.domain.Season;
import gravit.code.domain.season.domain.SeasonStatus;
import gravit.code.domain.season.infrastructure.SeasonRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.time.temporal.TemporalAdjusters;
import java.time.temporal.WeekFields;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class SeasonService {
    private final SeasonRepository seasonRepository;
    private final Clock clock;

    @Transactional
    public Season getOrCreateActiveSeason(){

        // ACTIVE 인 시즌이 있다면 가져오기
        Optional<Season> activeSeason  = seasonRepository.findByStatus(SeasonStatus.ACTIVE);
        if(activeSeason.isPresent()) return activeSeason.get();

        // ACTIVE 인 시즌이 없다면 PREP 시즌 찾아서 등록(추후 해당 시즌 시작시, ACTIVE 로 수정)
        Optional<Season> prepSeason = seasonRepository.findByStatus(SeasonStatus.PREP);
        if(prepSeason.isPresent()) return prepSeason.get();

        // FINALIZING 이 존재 -> 배치(해당 시즌 마무리-> history 저장 및 UserLeague 초기화) 진행중이라는 뜻
        // 새 시즌은 PREP 으로 만들기
        if(seasonRepository.existsByStatus(SeasonStatus.FINALIZING)){
            String seasonKey = computeNextSeasonKey();
            return seasonRepository.save(Season.prep(seasonKey, nextStartsAt(), nextEndsAt()));
        }

        // 정말 아무것도 없는 초기 부트스트랩 시 에만 ACTIVE 생성
        String seasonKey = computeThisSeasonKey();
        return seasonRepository.save(Season.active(seasonKey, startsAt(), endsAt()));
    }

    private String computeThisSeasonKey() {
        LocalDate monday = currentWeekMondayKst();
        return isoWeekKey(monday);
    }

    private LocalDateTime startsAt(){
        return currentWeekMondayKst().atStartOfDay();
    }

    private LocalDateTime endsAt(){
        return currentWeekMondayKst().plusWeeks(1).atStartOfDay();
    }

    private String computeNextSeasonKey() {
        LocalDate nextMonday = currentWeekMondayKst().plusWeeks(1);
        return isoWeekKey(nextMonday);
    }

    private LocalDateTime nextStartsAt() {
        return currentWeekMondayKst().plusWeeks(1).atStartOfDay();
    }

    private LocalDateTime nextEndsAt() {
        return currentWeekMondayKst().plusWeeks(2).atStartOfDay();
    }

    private LocalDate currentWeekMondayKst() {
        LocalDate todayKst = LocalDate.now(clock);
        return todayKst.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

    private static String isoWeekKey(LocalDate kstDate) {
        WeekFields wf = WeekFields.ISO;
        int week = kstDate.get(wf.weekOfWeekBasedYear());
        int year = kstDate.get(wf.weekBasedYear());
        return String.format("%d-W%02d", year, week);
    }

}
