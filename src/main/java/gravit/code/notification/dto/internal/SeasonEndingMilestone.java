package gravit.code.notification.dto.internal;

public record SeasonEndingMilestone(
        int daysBefore,
        String headline,
        String subText
) {
}
