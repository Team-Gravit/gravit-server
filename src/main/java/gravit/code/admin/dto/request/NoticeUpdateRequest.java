package gravit.code.admin.dto.request;

import gravit.code.notice.domain.NoticeStatus;
import jakarta.validation.constraints.NotNull;

public record NoticeUpdateRequest(

        @NotNull(message = "공지사항 아이디가 비어있습니다.")
        Long noticeId,

        @NotNull(message = "제목이 비어있습니다.")
        String title,

        @NotNull(message = "본문이 비어있습니다.")
        String content,

        @NotNull(message = "공지 상태가 비어있습니다.")
        NoticeStatus status,

        @NotNull(message = "상단 고정 여부가 비어있습니다.")
        Boolean pinned
) {
}
