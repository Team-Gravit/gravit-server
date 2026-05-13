package gravit.code.dailyLearningRecord.service;

import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DailyLearningRecordService {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    private final DailyLearningRecordRepository dailyLearningRecordRepository;

    @Transactional(readOnly = true)
    public WeeklyLearningRecordResponse getWeeklyLearningRecord(long userId) {
        LocalDate today = LocalDate.now(KST);
        LocalDate monday = today.with(DayOfWeek.MONDAY);
        LocalDate sunday = today.with(DayOfWeek.SUNDAY);

        Set<DayOfWeek> solvedDays = dailyLearningRecordRepository
                .findSolvedDatesByUserIdAndDateRange(userId, monday, sunday)
                .stream()
                .map(LocalDate::getDayOfWeek)
                .collect(Collectors.toUnmodifiableSet());

        return new WeeklyLearningRecordResponse(
                solvedDays.contains(DayOfWeek.MONDAY),
                solvedDays.contains(DayOfWeek.TUESDAY),
                solvedDays.contains(DayOfWeek.WEDNESDAY),
                solvedDays.contains(DayOfWeek.THURSDAY),
                solvedDays.contains(DayOfWeek.FRIDAY),
                solvedDays.contains(DayOfWeek.SATURDAY),
                solvedDays.contains(DayOfWeek.SUNDAY)
        );
    }
}
