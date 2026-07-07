package gravit.code.global.util;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

// 생성 시각을 상대 표현으로 변환한다. 알림함·소셜 피드 공통 사용(표기 규칙 단일화).
// 1시간 이내 → N분 전 / 1~24시간 → N시간 전 / 어제 → 어제 / 2~6일 → N일 전 / 7일 이상 → N주 전
// 시각 기준은 주입된 Clock(Asia/Seoul)을 따른다 — 서버 타임존과 무관하게 KST로 처리된다.
@Component
@RequiredArgsConstructor
public class TimeAgoFormatter {

    private static final long DAYS_PER_WEEK = 7;

    private final Clock clock;

    public String format(LocalDateTime createdAt) {
        LocalDateTime now = LocalDateTime.now(clock);

        long minutes = ChronoUnit.MINUTES.between(createdAt, now);
        if (minutes < 60) {
            return Math.max(1, minutes) + "분 전";
        }

        long hours = ChronoUnit.HOURS.between(createdAt, now);
        if (hours < 24) {
            return hours + "시간 전";
        }

        long days = ChronoUnit.DAYS.between(createdAt, now);
        if (days == 1) {
            return "어제";
        }
        if (days < DAYS_PER_WEEK) {
            return days + "일 전";
        }
        return (days / DAYS_PER_WEEK) + "주 전";
    }
}
