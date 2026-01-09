package gravit.code.admin.service;

import gravit.code.admin.dto.response.AdminNoticeDetailResponse;
import gravit.code.admin.dto.response.AdminNoticeSummaryResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notice.domain.Notice;
import gravit.code.notice.infrastructure.NoticeRepository;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminNoticeQueryService {

    private static final int PAGE_SIZE = 10;
    private static final int SUMMARY_MAX_SIZE = 70;

    // 정렬 규칙
    private static final Sort NOTICE_LIST_SORT = Sort.by(
            Sort.Order.desc("pinned"),
            Sort.Order.desc("id")
    );

    private final NoticeRepository noticeRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public AdminNoticeDetailResponse getNoticeByAdmin(long userId, long noticeId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        if(user.getRole() != Role.ADMIN){
            throw new RestApiException(CustomErrorCode.ADMIN_ONLY_FEATURE);
        }

        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(()->new RestApiException(CustomErrorCode.NOTICE_NOT_FOUND));

        return AdminNoticeDetailResponse.from(notice);
    }

    @Transactional(readOnly = true)
    public PageResponse<AdminNoticeSummaryResponse> getNoticeSummaryByAdmin(long userId, int page) {
        User user = userRepository.findById(userId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.USER_NOT_FOUND));

        if(user.getRole() != Role.ADMIN){
            throw new RestApiException(CustomErrorCode.ADMIN_ONLY_FEATURE);
        }

        if(page < 1) throw new RestApiException(CustomErrorCode.PAGE_MUST_START_FROM_1);
        int realPage = page - 1;

        Pageable pageable = noticePageable(realPage);
        Page<AdminNoticeSummaryResponse> summariesForAdmin = noticeRepository.findSummariesForAdmin(SUMMARY_MAX_SIZE, pageable);

        return PageResponse.from(summariesForAdmin);
    }

    private Pageable noticePageable(int page) {
        int safePage = Math.max(0, page);
        return PageRequest.of(safePage, PAGE_SIZE, NOTICE_LIST_SORT);
    }
}

