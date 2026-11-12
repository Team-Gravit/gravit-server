package gravit.code.user.service;

import gravit.code.user.repository.UserDailyActivityRepository;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserAccessService {

    private final UserRepository userRepository;
    private final UserDailyActivityRepository userDailyActivityRepository;

    private final Clock clock;

    @Transactional
    public void updateLastAccessed(long userId) {
        LocalDateTime now = LocalDateTime.now(clock);
        LocalDate today = now.toLocalDate();

        int updated = userRepository.updateLastAccessedAt(userId, now, today.atStartOfDay());
        if (updated == 0) {
            return;
        }

        userDailyActivityRepository.insertIfAbsent(userId, today);
    }

    @Transactional(readOnly = true)
    public List<Long> getUserIdsInactiveForExactly(int inactiveDays) {
        LocalDateTime start = LocalDate.now(clock).minusDays(inactiveDays).atStartOfDay();
        LocalDateTime end = start.plusDays(1);

        return userRepository.findUserIdsLastAccessedBetween(start, end);
    }
}
