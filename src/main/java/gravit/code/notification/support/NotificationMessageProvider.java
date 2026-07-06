package gravit.code.notification.support;

import gravit.code.notification.dto.internal.InactivityMilestone;
import gravit.code.notification.dto.internal.SeasonEndingMilestone;
import gravit.code.social.domain.FeedEventType;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@Component
public class NotificationMessageProvider {

    private static final String CONSECUTIVE_WARNING_MESSAGE = "%d일 연속학습이 끊길 위기예요!";

    private static final String CONSECUTIVE_WARNING_SUB_TEXT = "오늘 학습하면 계속 이어갈 수 있어요";

    private static final String NOTICE_HEADLINE = "새로운 공지사항이 있어요";

    private static final String NEW_CONTENT_MESSAGE = "새 레슨이 업데이트됐어요! 오늘 학습에 도전해보세요 🔥";

    private static final String SEASON_RESET_MESSAGE = "시즌 종료! 새 시즌이 찾아왔어요. 다시 시작해봐요 💪";

    private static final List<SeasonEndingMilestone> SEASON_ENDING_MILESTONES = List.of(
            new SeasonEndingMilestone(7, "시즌이 일주일 뒤 끝나요!", "지금이 티어 올릴 마지막 기회예요 💪"),
            new SeasonEndingMilestone(3, "시즌 종료가 3일 앞으로 다가왔어요!", "마지막까지 달려봐요 🔥")
    );

    private static final List<String> DAILY_INCOMPLETE_MESSAGES = List.of(
            "오늘 아직 학습을 안 했어요! 10분만 투자해보세요 📚",
            "오늘 학습을 시작해보세요! 작은 습관이 큰 변화를 만들어요 🌱",
            "지금 이 시간에도 누군가는 CS를 공부하고 있어요 👀"
    );

    // 장기 미접속 마일스톤. 60·90·120일은 기획 문구 미정이라 확정 후 아래 목록에 추가하면 동작한다.
    private static final List<InactivityMilestone> INACTIVITY_MILESTONES = List.of(
            new InactivityMilestone(7, "벌써 일주일이 지났어요 😢 Gravit이 기다리고 있어요!"),
            new InactivityMilestone(14, "14일이 지났어요. 슬슬 돌아올 때가 된 것 같은데요? 👀"),
            new InactivityMilestone(30, "한 달 동안 보고 싶었어요 😭 지금 돌아와도 늦지 않아요!")
    );

    public String consecutiveWarning(int consecutiveDays) {
        return CONSECUTIVE_WARNING_MESSAGE.formatted(consecutiveDays);
    }

    public String consecutiveWarningSubText() {
        return CONSECUTIVE_WARNING_SUB_TEXT;
    }

    public String randomDailyIncomplete() {
        int index = ThreadLocalRandom.current().nextInt(DAILY_INCOMPLETE_MESSAGES.size());
        return DAILY_INCOMPLETE_MESSAGES.get(index);
    }

    public List<InactivityMilestone> inactivityMilestones() {
        return INACTIVITY_MILESTONES;
    }

    public String inactivity(int inactiveDays) {
        return INACTIVITY_MILESTONES.stream()
                .filter(milestone -> milestone.days() == inactiveDays)
                .map(InactivityMilestone::message)
                .findFirst()
                .orElseGet(() -> "%d일째 그래빗이 당신을 기다리고 있어요 🛜".formatted(inactiveDays));
    }

    // 공지 알림: 헤드라인은 고정, 공지 제목은 서브텍스트로 전달한다(3.12)
    public String noticeHeadline() {
        return NOTICE_HEADLINE;
    }

    // 3.14 문의 답변: 헤드라인에 문의 제목을 그대로 동적 삽입한다. 노출 길이 제한(말줄임)은 프론트에서 처리한다.
    public String inquiryAnswered(String title) {
        return "[%s]에 답변이 달렸어요!".formatted(title == null ? "" : title);
    }

    public String newContent() {
        return NEW_CONTENT_MESSAGE;
    }

    public List<SeasonEndingMilestone> seasonEndingMilestones() {
        return SEASON_ENDING_MILESTONES;
    }

    public String seasonReset() {
        return SEASON_RESET_MESSAGE;
    }

    public String followReceived(String followerNickname) {
        return followerNickname + "님이 나를 팔로우했어요! 👀";
    }

    public String congratulation(String congratulatorNickname) {
        return congratulatorNickname + "님이 축하해줬어요! 🎉";
    }

    public String friendActivity(
            String actorNickname,
            FeedEventType eventType,
            String eventValue
    ) {
        return switch (eventType) {
            case PLANET_COMPLETE -> actorNickname + "님이 " + eventValue + "행성을 정복했어요! 🌍";
            case STREAK_DAYS -> actorNickname + "님이 " + eventValue + "일 연속학습을 달성했어요! 🔥";
            case TIER_PROMOTION -> actorNickname + "님이 " + eventValue + "티어로 승급했어요! 🎉";
            case LEVEL_UP -> actorNickname + "님이 LV." + eventValue + "이 됐어요! 💪";
        };
    }
}
