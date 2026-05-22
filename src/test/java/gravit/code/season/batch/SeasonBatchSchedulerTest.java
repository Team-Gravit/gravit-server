package gravit.code.season.batch;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.scheduling.support.CronExpression;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatNoException;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class SeasonBatchSchedulerTest {

    @Mock
    SeasonBatchService seasonBatchService;

    @InjectMocks
    SeasonBatchScheduler scheduler;

    private static final String ROLLOVER_CRON = "0 0 0 1 1,5,9 *";

    @Nested
    @DisplayName("finalizeAndRollover 실행 테스트")
    class WhenTryQuarterlyRollover {

        @Test
        void 정상_실행_시_finalizeAndRollover를_한_번_호출한다() {
            doNothing().when(seasonBatchService).finalizeAndRollover();

            scheduler.tryQuarterlyRollover();

            verify(seasonBatchService, times(1)).finalizeAndRollover();
        }

        @Test
        void ACTIVE_시즌이_없으면_예외를_삼키고_정상_종료한다() {
            doThrow(new RestApiException(CustomErrorCode.ACTIVE_SEASON_NOT_FOUND))
                    .when(seasonBatchService).finalizeAndRollover();

            assertThatNoException().isThrownBy(() -> scheduler.tryQuarterlyRollover());
        }

        @Test
        void 그_외_RestApiException은_호출자로_전파된다() {
            doThrow(new RestApiException(CustomErrorCode.USER_NOT_FOUND))
                    .when(seasonBatchService).finalizeAndRollover();

            assertThatThrownBy(() -> scheduler.tryQuarterlyRollover())
                    .isInstanceOf(RestApiException.class);
        }
    }

    @Nested
    @DisplayName("Scheduler 발동 테스트")
    class CronScheduleVerification {

        private CronExpression cron;

        @BeforeEach
        void setUp() {
            cron = CronExpression.parse(ROLLOVER_CRON);
        }

        @Test
        void 일월_1일_자정_이후_다음_발동_시각은_5월_1일_자정이다() {
            LocalDateTime afterJan = LocalDateTime.of(2025, 1, 1, 0, 0, 1);

            LocalDateTime next = cron.next(afterJan);

            assertThat(next).isEqualTo(LocalDateTime.of(2025, 5, 1, 0, 0, 0));
        }

        @Test
        void 오월_1일_자정_이후_다음_발동_시각은_9월_1일_자정이다() {
            LocalDateTime afterMay = LocalDateTime.of(2025, 5, 1, 0, 0, 1);

            LocalDateTime next = cron.next(afterMay);

            assertThat(next).isEqualTo(LocalDateTime.of(2025, 9, 1, 0, 0, 0));
        }

        @Test
        void 구월_1일_자정_이후_다음_발동_시각은_이듬해_1월_1일_자정이다() {
            LocalDateTime afterSep = LocalDateTime.of(2025, 9, 1, 0, 0, 1);

            LocalDateTime next = cron.next(afterSep);

            assertThat(next).isEqualTo(LocalDateTime.of(2026, 1, 1, 0, 0, 0));
        }

        @Test
        void 연간_발동_횟수는_정확히_3회다() {
            LocalDateTime start = LocalDateTime.of(2024, 12, 31, 23, 59, 59);
            LocalDateTime endOfYear = LocalDateTime.of(2026, 1, 1, 0, 0, 0);

            int count = 0;
            LocalDateTime cursor = start;
            while (true) {
                cursor = cron.next(cursor);
                if (cursor == null || !cursor.isBefore(endOfYear)) break;
                count++;
            }

            assertThat(count).isEqualTo(3);
        }
    }
}
