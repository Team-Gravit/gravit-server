package gravit.code.admin.controller;

import gravit.code.admin.controller.docs.AdminMeControllerDocs;
import gravit.code.admin.dto.response.AdminMeResponse;
import gravit.code.admin.service.AdminMeService;
import gravit.code.auth.domain.LoginUser;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/admin/me")
public class AdminMeController implements AdminMeControllerDocs {

    private final AdminMeService adminMeService;

    @GetMapping
    public ResponseEntity<AdminMeResponse> getMe(@AuthenticationPrincipal LoginUser loginUser) {
        return ResponseEntity.status(OK).body(adminMeService.getMe(loginUser.getId()));
    }
}
