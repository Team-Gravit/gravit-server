package gravit.code.dailyLearningRecord.service;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.domain.DayTiming;
import gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse;
import gravit.code.dailyLearningRecord.dto.response.DayLearningRecordResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningReportResponse;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.global.consts.TimeZoneConst;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DailyLearningRecordService {

    private static final int COMPARED_WEEK_COUNT = 3;

    private final DailyLearningRecordRepository dailyLearningRecordRepository;

    private final Clock clock;

    @Transactional(readOnly = true)
    public Map<DayOfWeek, DayLearningRecordResponse> getWeeklyDayRecords(long userId) {
        LocalDate today = LocalDate.now(clock);
        LocalDate monday = today.with(DayOfWeek.MONDAY);
        LocalDate sunday = today.with(DayOfWeek.SUNDAY);

        Set<LocalDate> solvedDates = Set.copyOf(
                dailyLearningRecordRepository.findSolvedDatesByUserIdAndDateRange(userId, monday, sunday)
        );

        return monday.datesUntil(sunday.plusDays(1))
                .collect(Collectors.toUnmodifiableMap(
                        LocalDate::getDayOfWeek,
                        date -> DayLearningRecordResponse.of(DayTiming.of(date, today), solvedDates.contains(date))
                ));
    }

    @Transactional(readOnly = true)
    public List<DailySolvedCountResponse> getDailySolvedCounts(
            long userId,
            int year
    ) {
        LocalDate today = LocalDate.now(TimeZoneConst.KST);
        LocalDate beginDate = LocalDate.of(year, 1, 1);
        LocalDate yearEnd = LocalDate.of(year, 12, 31);
        LocalDate endDate = yearEnd.isAfter(today) ? today : yearEnd;

        return dailyLearningRecordRepository.findDailySolvedCountsByUserIdBetween(userId, beginDate, endDate);
    }

    @Transactional(readOnly = true)
    public WeeklyLearningReportResponse getWeeklyLearningReport(long userId) {
        LocalDate today = LocalDate.now(TimeZoneConst.KST);
        LocalDate thisMonday = today.with(DayOfWeek.MONDAY);
        LocalDate thisSunday = today.with(DayOfWeek.SUNDAY);
        LocalDate oldestComparedMonday = thisMonday.minusWeeks(COMPARED_WEEK_COUNT);

        List<DailyLearningRecord> records = dailyLearningRecordRepository
                .findByUserIdAndSolvedDateBetween(userId, oldestComparedMonday, thisSunday);

        Map<DayOfWeek, Integer> dayOfWeekToCount = records.stream()
                .filter(dlr -> !dlr.getSolvedDate().isBefore(thisMonday))
                .collect(Collectors.toMap(
                        dlr -> dlr.getSolvedDate().getDayOfWeek(),
                        DailyLearningRecord::getSolvedLessonCount
                ));

        Map<LocalDate, Integer> weekStartToCount = records.stream()
                .collect(Collectors.groupingBy(
                        dlr -> dlr.getSolvedDate().with(DayOfWeek.MONDAY),
                        Collectors.summingInt(DailyLearningRecord::getSolvedLessonCount)
                ));

        int thisWeekCompletedLessonCount = weekStartToCount.getOrDefault(thisMonday, 0);

        List<Integer> weekOverWeekDeltas = new ArrayList<>(COMPARED_WEEK_COUNT);
        for (int weeksAgo = 1; weeksAgo <= COMPARED_WEEK_COUNT; weeksAgo++) {
            int pastWeekCount = weekStartToCount.getOrDefault(thisMonday.minusWeeks(weeksAgo), 0);
            weekOverWeekDeltas.add(thisWeekCompletedLessonCount - pastWeekCount);
        }

        return WeeklyLearningReportResponse.of(
                dayOfWeekToCount,
                thisWeekCompletedLessonCount,
                weekOverWeekDeltas
        );
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void handleDailyLearningRecord(long userId) {
        LocalDate today = LocalDate.now(TimeZoneConst.KST);

        DailyLearningRecord dailyLearningRecord = dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today)
                .orElseGet(() -> DailyLearningRecord.create(userId, today));

        dailyLearningRecord.increaseSolvedLessonCount();

        dailyLearningRecordRepository.save(dailyLearningRecord);
    }
}
