package gravit.code.admin.service;

import gravit.code.admin.dto.request.InquiryAnswerCreateRequest;
import gravit.code.admin.dto.request.InquiryAnswerUpdateRequest;
import gravit.code.admin.dto.response.InquiryDetailResponse;
import gravit.code.admin.dto.response.InquiryListItemResponse;
import gravit.code.admin.support.AdminPages;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.event.InquiryAnsweredEvent;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryAnswer;
import gravit.code.inquiry.domain.InquiryStatus;
import gravit.code.inquiry.repository.InquiryAnswerRepository;
import gravit.code.inquiry.repository.InquiryRepository;
import gravit.code.user.domain.User;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminInquiryService {

    private final InquiryRepository inquiryRepository;
    private final InquiryAnswerRepository inquiryAnswerRepository;
    private final UserRepository userRepository;
    private final ApplicationEventPublisher publisher;

    private static final Sort INQUIRY_LIST_SORT = Sort.by(Sort.Order.desc("id"));

    @Transactional(readOnly = true)
    public PageResponse<InquiryListItemResponse> getInquiries(
            InquiryStatus status,
            int page
    ) {
        Pageable pageable = AdminPages.of(page, INQUIRY_LIST_SORT);
        Page<Inquiry> inquiries = (status == null)
                ? inquiryRepository.findAll(pageable)
                : inquiryRepository.findAllByStatus(status, pageable);

        Map<Long, User> submittersById = loadSubmitters(inquiries.getContent());

        return PageResponse.from(
                inquiries.map(inquiry -> InquiryListItemResponse.of(inquiry, submittersById.get(inquiry.getUserId())))
        );
    }

    @Transactional(readOnly = true)
    public InquiryDetailResponse getInquiry(long inquiryId) {
        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_NOT_FOUND));

        InquiryAnswer answer = inquiryAnswerRepository.findByInquiryId(inquiryId).orElse(null);

        User submitter = userRepository.findById(inquiry.getUserId()).orElse(null);

        return InquiryDetailResponse.of(inquiry, submitter, answer);
    }

    @Transactional
    public InquiryDetailResponse answer(
            long adminId,
            long inquiryId,
            InquiryAnswerCreateRequest request
    ) {
        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_NOT_FOUND));

        if (inquiryAnswerRepository.findByInquiryId(inquiryId).isPresent()) {
            throw new RestApiException(CustomErrorCode.INQUIRY_ALREADY_ANSWERED);
        }

        InquiryAnswer answer = inquiryAnswerRepository.save(
                InquiryAnswer.create(inquiryId, request.content(), adminId)
        );
        inquiry.resolve();

        publisher.publishEvent(new InquiryAnsweredEvent(inquiryId, inquiry.getUserId(), inquiry.getTitle()));

        User submitter = userRepository.findById(inquiry.getUserId()).orElse(null);

        return InquiryDetailResponse.of(inquiry, submitter, answer);
    }

    @Transactional
    public InquiryDetailResponse updateAnswer(
            long inquiryId,
            InquiryAnswerUpdateRequest request
    ) {
        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_NOT_FOUND));

        InquiryAnswer answer = inquiryAnswerRepository.findByInquiryId(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_ANSWER_NOT_FOUND));

        answer.update(request.content());

        User submitter = userRepository.findById(inquiry.getUserId()).orElse(null);

        return InquiryDetailResponse.of(inquiry, submitter, answer);
    }

    @Transactional
    public void deleteAnswer(long inquiryId) {
        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_NOT_FOUND));

        InquiryAnswer answer = inquiryAnswerRepository.findByInquiryId(inquiryId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.INQUIRY_ANSWER_NOT_FOUND));

        inquiryAnswerRepository.delete(answer);

        inquiry.reopen();
    }

    private Map<Long, User> loadSubmitters(List<Inquiry> inquiries) {
        Set<Long> userIds = inquiries.stream()
                .map(Inquiry::getUserId)
                .collect(Collectors.toSet());

        if (userIds.isEmpty()) {
            return Map.of();
        }

        return userRepository.findAllById(userIds).stream()
                .collect(Collectors.toMap(User::getId, Function.identity()));
    }
}
