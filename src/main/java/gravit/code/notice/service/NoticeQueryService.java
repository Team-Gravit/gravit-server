package gravit.code.notice.service;

import gravit.code.global.dto.SliceResponse;
import gravit.code.notice.domain.Notice;
import gravit.code.notice.domain.NoticeStatus;
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

    // 정렬 규칙
    private static final Sort NOTICE_LIST_SORT = Sort.by(
            Sort.Order.desc("pinned"),
            Sort.Order.desc("publishedAt"),
            Sort.Order.desc("id")
    );

    @Transactional(readOnly = true)
    public SliceResponse<NoticeSummaryResponse> getNoticeSummaries(int page){
        Pageable pageable = noticePageable(page);
        Slice<Notice> sliceResult = noticeRepository.findAllByStatus(NoticeStatus.PUBLISHED, pageable);

        List<NoticeSummaryResponse> results = sliceResult.stream()
                .map(NoticeSummaryResponse::from)
                .toList();

        return SliceResponse.of(sliceResult.hasNext(), results);
    }

    private Pageable noticePageable(int page) {
        int safePage = Math.max(0, page);
        return PageRequest.of(safePage, PAGE_SIZE, NOTICE_LIST_SORT);
    }

}
