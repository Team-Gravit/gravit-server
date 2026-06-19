package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminInquiryControllerDocs;
import gravit.code.admin.dto.request.InquiryAnswerCreateRequest;
import gravit.code.admin.dto.request.InquiryAnswerUpdateRequest;
import gravit.code.admin.dto.response.InquiryDetailResponse;
import gravit.code.admin.dto.response.InquiryListItemResponse;
import gravit.code.admin.service.AdminInquiryService;
import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.inquiry.domain.InquiryStatus;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/inquiries")
public class AdminInquiryController implements AdminInquiryControllerDocs {

    private final AdminInquiryService adminInquiryService;

    @GetMapping
    public ResponseEntity<PageResponse<InquiryListItemResponse>> getInquiries(
            @RequestParam(value = "status", required = false) InquiryStatus status,
            @RequestParam(value = "page", defaultValue = "1") int page
    ) {
        return ResponseEntity.ok(adminInquiryService.getInquiries(status, page));
    }

    @GetMapping("/{inquiryId}")
    public ResponseEntity<InquiryDetailResponse> getInquiry(@PathVariable("inquiryId") long inquiryId) {
        return ResponseEntity.ok(adminInquiryService.getInquiry(inquiryId));
    }

    @PostMapping("/{inquiryId}/answer")
    public ResponseEntity<InquiryDetailResponse> answerInquiry(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("inquiryId") long inquiryId,
            @Valid @RequestBody InquiryAnswerCreateRequest request
    ) {
        InquiryDetailResponse response = adminInquiryService.answer(loginUser.getId(), inquiryId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{inquiryId}/answer")
    public ResponseEntity<InquiryDetailResponse> updateAnswer(
            @PathVariable("inquiryId") long inquiryId,
            @Valid @RequestBody InquiryAnswerUpdateRequest request
    ) {
        return ResponseEntity.ok(adminInquiryService.updateAnswer(inquiryId, request));
    }

    @DeleteMapping("/{inquiryId}/answer")
    public ResponseEntity<Void> deleteAnswer(@PathVariable("inquiryId") long inquiryId) {
        adminInquiryService.deleteAnswer(inquiryId);
        return ResponseEntity.noContent().build();
    }
}
