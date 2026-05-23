package gravit.code.social.service;

import static gravit.code.global.exception.domain.CustomErrorCode.*;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.social.domain.Congratulation;
import gravit.code.social.repository.CongratulationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Service
@RequiredArgsConstructor
public class CongratulationCommandService {

    private static final int DAILY_LIMIT = 3;
    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");

    private final CongratulationRepository congratulationRepository;

    @Transactional
    public void checkAndRecord(
            long userId,
            long actorId,
            long feedId
    ) {
        LocalDateTime startOfDay = LocalDate.now(SEOUL).atStartOfDay();
        long todayCount = congratulationRepository.countTodayByUserIdAndActorId(userId, actorId, startOfDay);
        if (todayCount >= DAILY_LIMIT) {
            throw new RestApiException(CONGRATULATE_LIMIT_EXCEEDED);
        }
        try {
            congratulationRepository.saveAndFlush(Congratulation.create(userId, actorId, feedId));
        } catch (DataIntegrityViolationException e) {
            throw new RestApiException(ALREADY_CONGRATULATED);
        }
    }
}
