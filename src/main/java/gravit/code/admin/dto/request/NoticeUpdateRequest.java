package gravit.code.admin.dto.request;

import gravit.code.notice.domain.NoticeStatus;
import jakarta.validation.constraints.Size;

public record NoticeUpdateRequest(

        @Size(max = 50, message = "제목은 50자를 초과할 수 없습니다.")
        String title,

        @Size(max = 255, message = "요약은 255자를 초과할 수 없습니다.")
        String summary,

        String content,

        NoticeStatus status,

        Boolean pinned
) {
}
