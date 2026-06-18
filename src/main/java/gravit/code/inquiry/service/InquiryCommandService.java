package gravit.code.inquiry.service;

import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryType;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
import gravit.code.inquiry.dto.request.InquiryUpdateRequest;
import gravit.code.inquiry.repository.InquiryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class InquiryCommandService {

    private final InquiryRepository inquiryRepository;

    @Transactional
    public long submit(
            long userId,
            InquirySubmitRequest request
    ) {
        Inquiry inquiry = Inquiry.create(
                request.title(),
                InquiryType.valueOf(request.type()),
                request.content(),
                userId
        );
        return inquiryRepository.save(inquiry).getId();
    }

    @Transactional
    public void update(
            long userId,
            long inquiryId,
            InquiryUpdateRequest request
    ) {
        Inquiry inquiry = getOwnedInquiry(userId, inquiryId);
        inquiry.update(
                request.title(),
                InquiryType.valueOf(request.type()),
                request.content()
        );
    }

    @Transactional
    public void delete(
            long userId,
            long inquiryId
    ) {
        Inquiry inquiry = getOwnedInquiry(userId, inquiryId);
        inquiry.ensureModifiable();
        inquiryRepository.delete(inquiry);
    }

    private Inquiry getOwnedInquiry(
            long userId,
            long inquiryId
    ) {
        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_NOT_FOUND));

        if (!inquiry.isOwnedBy(userId)) {
            throw new RestApiException(CustomErrorCode.INQUIRY_FORBIDDEN);
        }
        return inquiry;
    }
}
