package gravit.code.admin.service;

import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.request.NoticeUpdateRequest;
import gravit.code.admin.dto.response.AdminNoticeDetailResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.repository.NoticeRepository;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminNoticeCommandService {

    private final NoticeRepository noticeRepository;
    private final UserRepository userRepository;

    @Transactional
    public AdminNoticeDetailResponse createNotice(
            long authorId,
            NoticeCreateRequest request
    ) {
        User author = userRepository.findById(authorId).orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));
        String title = request.title();
        String content = request.content();
        NoticeStatus status = request.status();
        boolean pinned = request.pinned();

        Notice notice = Notice.create(title, content, author, status, pinned);

        noticeRepository.save(notice);

        return AdminNoticeDetailResponse.from(notice);
    }

    @Transactional
    public AdminNoticeDetailResponse updateNotice(
            long authorId,
            NoticeUpdateRequest request
    ) {
        if(!userRepository.existsById(authorId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        Notice notice = noticeRepository.findById(request.noticeId()).orElseThrow(() -> new RestApiException(CustomErrorCode.NOTICE_NOT_FOUND));

        String title = request.title();
        String content = request.content();
        NoticeStatus status = request.status();
        boolean pinned = request.pinned();

        notice.update(title, content, status, pinned);

        return AdminNoticeDetailResponse.from(notice);
    }

    @Transactional
    public void deleteNotice(
            long authorId,
            long noticeId
    ) {
        if(!userRepository.existsById(authorId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        noticeRepository.deleteById(noticeId);
    }
}
