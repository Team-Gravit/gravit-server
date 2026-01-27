package gravit.code.notice.service;

import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.dto.response.NoticeDetailResponse;
import gravit.code.notice.dto.response.NoticeSummaryResponse;
import gravit.code.notice.repository.NoticeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NoticeQueryService {
    private final NoticeRepository noticeRepository;

    private static final int PAGE_SIZE = 10;
    private static final int SUMMARY_MAX_SIZE = 70;

    // 정렬 규칙
    private static final Sort NOTICE_LIST_SORT = Sort.by(
            Sort.Order.desc("pinned"),
            Sort.Order.desc("publishedAt"),
            Sort.Order.desc("id")
    );

    @Transactional(readOnly = true)
    public PageResponse<NoticeSummaryResponse> getNoticeSummaries(int page){
        if(page < 1) throw new RestApiException(CustomErrorCode.PAGE_MUST_START_FROM_1);
        int realPage = page - 1;
        Pageable pageable = noticePageable(realPage);
        Page<NoticeSummaryResponse> pageResult = noticeRepository.findSummaries(NoticeStatus.PUBLISHED, SUMMARY_MAX_SIZE, pageable);

        return PageResponse.from(pageResult);
    }

    @Transactional(readOnly = true)
    public NoticeDetailResponse getNoticeDetail(long noticeId){
        Notice notice = noticeRepository.findByIdAndStatus(noticeId, NoticeStatus.PUBLISHED)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.NOTICE_NOT_FOUND));
        return NoticeDetailResponse.from(notice);
    }

    private Pageable noticePageable(int page) {
        int safePage = Math.max(0, page);
        return PageRequest.of(safePage, PAGE_SIZE, NOTICE_LIST_SORT);
    }

}
