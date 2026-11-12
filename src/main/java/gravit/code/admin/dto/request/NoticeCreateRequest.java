package gravit.code.admin.dto.request;

import gravit.code.notice.domain.NoticeStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record NoticeCreateRequest(

        @NotBlank(message = "제목은 비어있을 수 없습니다.")
        @Size(max = 50, message = "제목은 50자를 초과할 수 없습니다.")
        String title,

        @NotBlank(message = "요약은 비어있을 수 없습니다.")
        @Size(max = 255, message = "요약은 255자를 초과할 수 없습니다.")
        String summary,

        @NotBlank(message = "본문은 비어있을 수 없습니다.")
        String content,

        @NotNull(message = "공지 상태는 필수입니다.")
        NoticeStatus status,

        @NotNull(message = "상단 고정 여부는 필수입니다.")
        Boolean pinned
) {
}
