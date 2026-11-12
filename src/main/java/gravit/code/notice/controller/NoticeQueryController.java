package gravit.code.notice.controller;

import gravit.code.global.dto.response.PageResponse;
import gravit.code.notice.controller.docs.NoticeQueryControllerDocs;
import gravit.code.notice.dto.response.NoticeDetailResponse;
import gravit.code.notice.dto.response.NoticeSummaryResponse;
import gravit.code.notice.service.NoticeQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/notice")
public class NoticeQueryController implements NoticeQueryControllerDocs {

    private final NoticeQueryService noticeQueryService;

    @GetMapping("/summaries/{page}")
    public ResponseEntity<PageResponse<NoticeSummaryResponse>> getNoticeSummaries(@PathVariable("page") int page){
        PageResponse<NoticeSummaryResponse> noticeSummaries = noticeQueryService.getNoticeSummaries(page);
        return ResponseEntity.status(OK).body(noticeSummaries);
    }

    @GetMapping("/{noticeId}")
    public ResponseEntity<NoticeDetailResponse> getNoticeSummary(@PathVariable("noticeId") Long noticeId){
        NoticeDetailResponse noticeDetail = noticeQueryService.getNoticeDetail(noticeId);
        return ResponseEntity.status(OK).body(noticeDetail);
    }
}
