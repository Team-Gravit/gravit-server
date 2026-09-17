package gravit.code.learning.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.learning.domain.Learning;
import gravit.code.learning.dto.internal.ConsecutiveAtRiskUserDto;
import gravit.code.learning.repository.LearningRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.LEARNING_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class LearningQueryService {

    private static final int ACTIVE_THRESHOLD_DAYS = 6;

    private final LearningRepository learningRepository;

    private final Clock clock;

    @Transactional(readOnly = true)
    public Learning getLearning(long userId) {
        return learningRepository.findByUserId(userId)
                .orElseThrow(() -> new RestApiException(LEARNING_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public List<ConsecutiveAtRiskUserDto> getConsecutiveAtRiskUsers() {
        return learningRepository.findConsecutiveAtRiskUsers(activeThreshold());
    }

    @Transactional(readOnly = true)
    public List<Long> getDailyIncompleteUserIds() {
        return learningRepository.findDailyIncompleteUserIds(activeThreshold());
    }

    private LocalDateTime activeThreshold() {
        return LocalDate.now(clock).minusDays(ACTIVE_THRESHOLD_DAYS).atStartOfDay();
    }
}
