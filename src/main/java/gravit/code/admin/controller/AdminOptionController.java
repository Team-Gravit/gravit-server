package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminOptionControllerDocs;
import gravit.code.admin.dto.request.OptionCreateRequest;
import gravit.code.admin.dto.request.OptionUpdateRequest;
import gravit.code.admin.service.AdminOptionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/options")
public class AdminOptionController implements AdminOptionControllerDocs {

    private final AdminOptionService adminOptionService;

    @PostMapping
    public ResponseEntity<Void> createOption(@Valid@RequestBody OptionCreateRequest createOption){
        adminOptionService.createOption(createOption);
        return ResponseEntity.noContent().build();
    }

    @PutMapping
    public ResponseEntity<Void> updateOption(@Valid @RequestBody OptionUpdateRequest request){
        adminOptionService.updateOption(request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{optionId}")
    public ResponseEntity<Void> deleteOption(@PathVariable("optionId") Long optionId){
        adminOptionService.deleteOption(optionId);
        return ResponseEntity.noContent().build();
    }
}
