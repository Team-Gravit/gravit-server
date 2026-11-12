package gravit.code.inquiry.service;

import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryType;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
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
}
