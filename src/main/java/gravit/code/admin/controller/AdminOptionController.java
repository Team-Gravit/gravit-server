package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminOptionControllerDocs;
import gravit.code.admin.dto.request.OptionCreateRequest;
import gravit.code.admin.dto.request.OptionUpdateRequest;
import gravit.code.admin.service.AdminOptionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/options")
public class AdminOptionController implements AdminOptionControllerDocs {

    private final AdminOptionService adminOptionService;

    @PostMapping
    public ResponseEntity<Void> createOption(@Valid@RequestBody OptionCreateRequest request){
        adminOptionService.createOption(request);
        return ResponseEntity.noContent().build();
    }

    @PutMapping
    public ResponseEntity<Void> updateOption(@Valid@RequestBody OptionUpdateRequest request){
        adminOptionService.updateOption(request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{optionId}")
    public ResponseEntity<Void> deleteOption(@PathVariable("optionId") Long optionId){
        adminOptionService.deleteOption(optionId);
        return ResponseEntity.noContent().build();
    }
}
