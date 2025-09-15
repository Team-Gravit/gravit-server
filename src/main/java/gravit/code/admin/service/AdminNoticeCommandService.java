package gravit.code.admin.service;

import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.response.NoticeResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.infrastructure.NoticeRepository;
import gravit.code.user.domain.User;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminNoticeCommandService {

    private final NoticeRepository noticeRepository;
    private final UserRepository userRepository;

    @Transactional
    public NoticeResponse createNotice(Long authorId, NoticeCreateRequest request) {
        User author = userRepository.findById(authorId).orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
        String title = request.title();
        String content = request.content();
        NoticeStatus status = request.status();
        boolean pinned = request.pinned();

        Notice notice = Notice.create(title, content, author, status, pinned);

        noticeRepository.save(notice);

        return NoticeResponse.from(notice);
    }
}
