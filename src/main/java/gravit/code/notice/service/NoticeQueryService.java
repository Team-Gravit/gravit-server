package gravit.code.notice.service;

import gravit.code.global.dto.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
import gravit.code.notice.dto.response.NoticeDetailResponse;
import gravit.code.notice.dto.response.NoticeSummaryResponse;
import gravit.code.notice.infrastructure.NoticeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

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
    public SliceResponse<NoticeSummaryResponse> getNoticeSummaries(int page){
        Pageable pageable = noticePageable(page);
        Slice<NoticeSummaryResponse> sliceResult = noticeRepository.findSummaries(NoticeStatus.PUBLISHED, SUMMARY_MAX_SIZE, pageable);

        return SliceResponse.of(sliceResult.hasNext(), sliceResult.getContent());
    }

    @Transactional(readOnly = true)
    public NoticeDetailResponse getNoticeDetail(long noticeId){
        Notice notice = noticeRepository.findById(noticeId).orElseThrow(() -> new RestApiException(CustomErrorCode.NOTICE_NOT_FOUND));
        return NoticeDetailResponse.from(notice);
    }

    private Pageable noticePageable(int page) {
        int safePage = Math.max(0, page);
        return PageRequest.of(safePage, PAGE_SIZE, NOTICE_LIST_SORT);
    }

}
