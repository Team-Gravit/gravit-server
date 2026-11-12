package gravit.code.global.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("상대시간 표기(TimeAgoFormatter, 알림·피드 공통)는")
class TimeAgoFormatterTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    // 고정 Clock을 주입해 now()와 formatter가 동일 기준시각을 공유하도록 한다(경계값 flaky 제거)
    private final Clock clock = Clock.fixed(Instant.parse("2026-07-01T03:00:00Z"), KST);
    private final TimeAgoFormatter formatter = new TimeAgoFormatter(clock);

    private LocalDateTime now() {
        return LocalDateTime.now(clock);
    }

    @Test
    @DisplayName("1분 미만이면 1분 전으로 표기한다 (방금 전 미사용)")
    void 일분_미만() {
        assertThat(formatter.format(now().minusSeconds(30))).isEqualTo("1분 전");
    }

    @Test
    @DisplayName("1시간 이내는 N분 전으로 표기한다")
    void 분_단위() {
        assertThat(formatter.format(now().minusMinutes(30))).isEqualTo("30분 전");
        assertThat(formatter.format(now().minusMinutes(59))).isEqualTo("59분 전");
    }

    @Test
    @DisplayName("1시간 ~ 24시간은 N시간 전으로 표기한다")
    void 시간_단위() {
        assertThat(formatter.format(now().minusHours(3))).isEqualTo("3시간 전");
        assertThat(formatter.format(now().minusHours(23))).isEqualTo("23시간 전");
    }

    @Test
    @DisplayName("1일 전은 어제로 표기한다")
    void 어제() {
        assertThat(formatter.format(now().minusDays(1))).isEqualTo("어제");
    }

    @Test
    @DisplayName("2일 ~ 6일은 N일 전으로 표기한다")
    void 일_단위() {
        assertThat(formatter.format(now().minusDays(2))).isEqualTo("2일 전");
        assertThat(formatter.format(now().minusDays(6))).isEqualTo("6일 전");
    }

    @Test
    @DisplayName("7일 ~ 30일은 N주 전(일수/7)으로 표기한다")
    void 주_단위() {
        assertThat(formatter.format(now().minusDays(7))).isEqualTo("1주 전");
        assertThat(formatter.format(now().minusDays(13))).isEqualTo("1주 전");
        assertThat(formatter.format(now().minusDays(14))).isEqualTo("2주 전");
        assertThat(formatter.format(now().minusDays(30))).isEqualTo("4주 전");
    }
}
