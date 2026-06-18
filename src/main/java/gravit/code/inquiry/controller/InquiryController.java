package gravit.code.inquiry.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.inquiry.controller.docs.InquiryControllerDocs;
import gravit.code.inquiry.dto.request.InquirySubmitRequest;
import gravit.code.inquiry.dto.request.InquiryUpdateRequest;
import gravit.code.inquiry.dto.response.InquiryDetailResponse;
import gravit.code.inquiry.dto.response.InquirySummaryResponse;
import gravit.code.inquiry.service.InquiryCommandService;
import gravit.code.inquiry.service.InquiryQueryService;
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
@RequestMapping("/api/v1/inquiries")
public class InquiryController implements InquiryControllerDocs {

    private final InquiryCommandService inquiryCommandService;
    private final InquiryQueryService inquiryQueryService;

    @PostMapping
    public ResponseEntity<Long> submitInquiry(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody InquirySubmitRequest request
    ) {
        long inquiryId = inquiryCommandService.submit(loginUser.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(inquiryId);
    }

    @GetMapping
    public ResponseEntity<PageResponse<InquirySummaryResponse>> getMyInquiries(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(value = "page", defaultValue = "1") int page
    ) {
        return ResponseEntity.ok(inquiryQueryService.getMyInquiries(loginUser.getId(), page));
    }

    @GetMapping("/{inquiryId}")
    public ResponseEntity<InquiryDetailResponse> getMyInquiryDetail(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("inquiryId") long inquiryId
    ) {
        return ResponseEntity.ok(inquiryQueryService.getMyInquiryDetail(loginUser.getId(), inquiryId));
    }

    @PutMapping("/{inquiryId}")
    public ResponseEntity<Void> updateInquiry(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("inquiryId") long inquiryId,
            @Valid @RequestBody InquiryUpdateRequest request
    ) {
        inquiryCommandService.update(loginUser.getId(), inquiryId, request);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{inquiryId}")
    public ResponseEntity<Void> deleteInquiry(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable("inquiryId") long inquiryId
    ) {
        inquiryCommandService.delete(loginUser.getId(), inquiryId);
        return ResponseEntity.noContent().build();
    }
}
