package gravit.code.dailyLearningRecord.facade;

import gravit.code.dailyLearningRecord.dto.response.DayLearningRecordResponse;
import gravit.code.dailyLearningRecord.dto.response.WeeklyLearningRecordResponse;
import gravit.code.dailyLearningRecord.service.DailyLearningRecordService;
import gravit.code.global.annotation.Facade;
import gravit.code.learning.service.LearningQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.util.Map;

@Facade
@RequiredArgsConstructor
public class DailyLearningRecordFacade {

    private final DailyLearningRecordService dailyLearningRecordService;
    private final LearningQueryService learningQueryService;

    @Transactional(readOnly = true)
    public WeeklyLearningRecordResponse getWeeklyLearningRecord(long userId) {
        int consecutiveSolvedDays = learningQueryService.getLearning(userId).getConsecutiveSolvedDays();

        Map<DayOfWeek, DayLearningRecordResponse> dayOfWeekToRecord = dailyLearningRecordService.getWeeklyDayRecords(userId);

        return WeeklyLearningRecordResponse.of(consecutiveSolvedDays, dayOfWeekToRecord);
    }
}
