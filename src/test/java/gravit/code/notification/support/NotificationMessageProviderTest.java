package gravit.code.notification.support;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("알림 문구 생성(NotificationMessageProvider)은")
class NotificationMessageProviderTest {

    private final NotificationMessageProvider messageProvider = new NotificationMessageProvider();

    @Test
    @DisplayName("문의 답변 헤드라인에 문의 제목을 대괄호로 감싸 삽입한다")
    void 문의_답변_헤드라인_제목_삽입() {
        assertThat(messageProvider.inquiryAnswered("로그인이 안돼요"))
                .isEqualTo("[로그인이 안돼요]에 답변이 달렸어요!");
    }

    @Test
    @DisplayName("긴 제목도 자르지 않고 그대로 삽입한다(말줄임은 프론트 책임)")
    void 문의_답변_헤드라인_긴_제목_그대로() {
        String title = "가".repeat(25);

        assertThat(messageProvider.inquiryAnswered(title))
                .isEqualTo("[" + title + "]에 답변이 달렸어요!");
    }
}
