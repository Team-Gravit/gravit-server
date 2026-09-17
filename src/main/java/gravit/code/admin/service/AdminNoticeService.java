package gravit.code.admin.service;

import gravit.code.admin.domain.audit.AuditAction;
import gravit.code.admin.dto.request.NoticeCreateRequest;
import gravit.code.admin.dto.request.NoticeUpdateRequest;
import gravit.code.admin.dto.response.NoticeDetailResponse;
import gravit.code.admin.dto.response.NoticeListItemResponse;
import gravit.code.admin.support.AdminPages;
import gravit.code.admin.support.AuditLogRecorder;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.dto.event.NoticeCreatedEvent;
import gravit.code.notice.repository.NoticeRepository;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static gravit.code.global.exception.domain.CustomErrorCode.NOTICE_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.USER_NOT_FOUND;

@Service
@RequiredArgsConstructor
public class AdminNoticeService {

    private final NoticeRepository noticeRepository;
    private final UserRepository userRepository;

    private final AuditLogRecorder auditLogRecorder;

    private final ApplicationEventPublisher publisher;

    @Transactional(readOnly = true)
    public PageResponse<NoticeListItemResponse> getNotices(int page) {
        Pageable pageable = AdminPages.of(page);

        return PageResponse.from(noticeRepository.findAllForAdmin(pageable).map(NoticeListItemResponse::from));
    }

    @Transactional(readOnly = true)
    public NoticeDetailResponse getNotice(long noticeId) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new RestApiException(NOTICE_NOT_FOUND));

        return NoticeDetailResponse.from(notice);
    }

    @Transactional
    public NoticeDetailResponse createNotice(
            long adminId,
            NoticeCreateRequest request
    ) {
        User author = userRepository.findById(adminId)
                .orElseThrow(() -> new RestApiException(USER_NOT_FOUND));

        Notice notice = Notice.create(
                request.title(),
                request.summary(),
                request.content(),
                author,
                request.status(),
                request.pinned());

        noticeRepository.save(notice);

        if (request.status() == NoticeStatus.PUBLISHED) {
            publisher.publishEvent(new NoticeCreatedEvent(notice.getId(), request.title()));
        }

        return NoticeDetailResponse.from(notice);
    }

    @Transactional
    public NoticeDetailResponse updateNotice(
            long adminId,
            long noticeId,
            NoticeUpdateRequest request
    ) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new RestApiException(NOTICE_NOT_FOUND));
        NoticeStatus beforeStatus = notice.getStatus();

        String title = request.title() != null ? request.title() : notice.getTitle();
        String summary = request.summary() != null ? request.summary() : notice.getSummary();
        String content = request.content() != null ? request.content() : notice.getContent();
        NoticeStatus status = request.status() != null ? request.status() : notice.getStatus();
        boolean pinned = request.pinned() != null ? request.pinned() : notice.isPinned();

        notice.update(title, summary, content, status, pinned);

        if (beforeStatus != notice.getStatus()) {
            auditLogRecorder.record(adminId, AuditAction.NOTICE_STATUS_CHANGE, String.valueOf(noticeId), beforeStatus.name(), notice.getStatus().name());
        }

        return NoticeDetailResponse.from(notice);
    }

    @Transactional
    public void deleteNotice(
            long adminId,
            long noticeId
    ) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new RestApiException(NOTICE_NOT_FOUND));

        noticeRepository.delete(notice);

        auditLogRecorder.record(adminId, AuditAction.NOTICE_DELETE, String.valueOf(noticeId), null, null);
    }
}
