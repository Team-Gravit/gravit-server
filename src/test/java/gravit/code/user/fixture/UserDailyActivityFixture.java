package gravit.code.user.fixture;

import gravit.code.user.domain.UserDailyActivity;
import gravit.code.user.repository.UserDailyActivityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.test.context.TestComponent;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

@TestComponent
@RequiredArgsConstructor
public class UserDailyActivityFixture {

    private final UserDailyActivityRepository userDailyActivityRepository;

    public void 활동_이력(
            long userId,
            LocalDate... activityDates
    ) {
        List<UserDailyActivity> activities = Arrays.stream(activityDates)
                .map(activityDate -> UserDailyActivity.create(userId, activityDate))
                .toList();

        userDailyActivityRepository.saveAll(activities);
    }
}
