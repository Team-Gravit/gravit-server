package gravit.code.inquiry.service;

import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryAnswer;
import gravit.code.inquiry.dto.response.InquiryDetailResponse;
import gravit.code.inquiry.dto.response.InquirySummaryResponse;
import gravit.code.inquiry.repository.InquiryAnswerRepository;
import gravit.code.inquiry.repository.InquiryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InquiryQueryService {

    private final InquiryRepository inquiryRepository;
    private final InquiryAnswerRepository inquiryAnswerRepository;

    private static final int PAGE_SIZE = 10;
    private static final Sort INQUIRY_LIST_SORT = Sort.by(Sort.Order.desc("id"));

    @Transactional(readOnly = true)
    public PageResponse<InquirySummaryResponse> getMyInquiries(
            long userId,
            int page
    ) {
        if (page < 1) {
            throw new RestApiException(CustomErrorCode.PAGE_MUST_START_FROM_1);
        }
        Pageable pageable = PageRequest.of(page - 1, PAGE_SIZE, INQUIRY_LIST_SORT);
        Page<InquirySummaryResponse> pageResult = inquiryRepository.findAllByUserId(userId, pageable)
                .map(InquirySummaryResponse::from);

        return PageResponse.from(pageResult);
    }

    @Transactional(readOnly = true)
    public InquiryDetailResponse getMyInquiryDetail(
            long userId,
            long inquiryId
    ) {
        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_NOT_FOUND));

        if (!inquiry.isOwnedBy(userId)) {
            throw new RestApiException(CustomErrorCode.INQUIRY_FORBIDDEN);
        }

        InquiryAnswer answer = inquiryAnswerRepository.findByInquiryId(inquiryId)
                .orElse(null);

        return InquiryDetailResponse.of(inquiry, answer);
    }
}
