package gravit.code.inquiry.fixture;

import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryAnswer;
import gravit.code.inquiry.domain.InquiryType;
import org.springframework.test.util.ReflectionTestUtils;

public class InquiryFixture {

    public static Inquiry 기본_문의(
            long id,
            long userId
    ) {
        Inquiry inquiry = Inquiry.create(
                "오답노트에서 앱이 종료돼요",
                InquiryType.BUG_REPORT,
                "오답노트 화면에 진입하면 앱이 강제 종료됩니다.",
                userId
        );
        ReflectionTestUtils.setField(inquiry, "id", id);
        return inquiry;
    }

    public static InquiryAnswer 답변(
            long id,
            long inquiryId,
            long adminId
    ) {
        InquiryAnswer answer = InquiryAnswer.create(
                inquiryId,
                "확인 후 다음 배포에 반영했습니다.",
                adminId
        );
        ReflectionTestUtils.setField(answer, "id", id);
        return answer;
    }
}
