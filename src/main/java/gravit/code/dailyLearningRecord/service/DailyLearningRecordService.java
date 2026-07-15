package gravit.code.dailyLearningRecord.service;

import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.dto.response.DailySolvedCountResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningReportResponse;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.global.consts.TimeZoneConst;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    private final DailyLearningRecordRepository dailyLearningRecordRepository;

    @Transactional(readOnly = true)
    public Set<DayOfWeek> getWeeklySolvedDays(long userId) {
        LocalDate today = LocalDate.now(TimeZoneConst.KST);
        LocalDate monday = today.with(DayOfWeek.MONDAY);
        LocalDate sunday = today.with(DayOfWeek.SUNDAY);

        return dailyLearningRecordRepository.findSolvedDatesByUserIdAndDateRange(userId, monday, sunday).stream()
                .map(LocalDate::getDayOfWeek)
                .collect(Collectors.toUnmodifiableSet());
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
        LocalDate threeWeeksAgoMonday = thisMonday.minusWeeks(3);

        List<DailyLearningRecord> records = dailyLearningRecordRepository
                .findByUserIdAndSolvedDateBetween(userId, threeWeeksAgoMonday, thisSunday);

        Map<DayOfWeek, Integer> thisWeekCountsByDay = records.stream()
                .filter(dlr -> !dlr.getSolvedDate().isBefore(thisMonday))
                .collect(Collectors.toMap(
                        dlr -> dlr.getSolvedDate().getDayOfWeek(),
                        DailyLearningRecord::getSolvedLessonCount
                ));

        Map<LocalDate, Integer> countsByWeekStart = records.stream()
                .collect(Collectors.groupingBy(
                        dlr -> dlr.getSolvedDate().with(DayOfWeek.MONDAY),
                        Collectors.summingInt(DailyLearningRecord::getSolvedLessonCount)
                ));

        int thisWeekCompletedLessonCount = countsByWeekStart.getOrDefault(thisMonday, 0);

        List<Integer> weekOverWeekDeltas = new ArrayList<>(3);
        for (int weeksAgo = 1; weeksAgo <= 3; weeksAgo++) {
            int pastWeekCount = countsByWeekStart.getOrDefault(thisMonday.minusWeeks(weeksAgo), 0);
            weekOverWeekDeltas.add(thisWeekCompletedLessonCount - pastWeekCount);
        }

        return WeeklyLearningReportResponse.of(
                thisWeekCountsByDay,
                thisWeekCompletedLessonCount,
                weekOverWeekDeltas
        );
    }

    @Transactional
    public void handleDailyLearningRecord(long userId) {
        LocalDate today = LocalDate.now(TimeZoneConst.KST);

        DailyLearningRecord dailyLearningRecord = dailyLearningRecordRepository.findByUserIdAndSolvedDate(userId, today)
                .orElseGet(() -> DailyLearningRecord.create(userId, today));

        dailyLearningRecord.increaseSolvedLessonCount();

        dailyLearningRecordRepository.save(dailyLearningRecord);
    }
}
