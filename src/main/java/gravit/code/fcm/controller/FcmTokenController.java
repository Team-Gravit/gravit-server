package gravit.code.fcm.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.fcm.controller.docs.FcmTokenControllerDocs;
import gravit.code.fcm.dto.request.RegisterFcmTokenRequest;
import gravit.code.fcm.dto.response.FcmTokenExistsResponse;
import gravit.code.fcm.service.FcmTokenCommandService;
import gravit.code.fcm.service.FcmTokenQueryService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Validated
@RequestMapping("/api/v1/fcm-tokens")
public class FcmTokenController implements FcmTokenControllerDocs {

    private final FcmTokenQueryService fcmTokenQueryService;
    private final FcmTokenCommandService fcmTokenCommandService;

    @PostMapping
    public ResponseEntity<Void> registerFcmToken(
            @AuthenticationPrincipal LoginUser loginUser,
            @Valid @RequestBody RegisterFcmTokenRequest request
    ){
        fcmTokenCommandService.registerFcmToken(loginUser.getId(), request);
        return ResponseEntity.status(HttpStatus.OK).build();
    }

    @GetMapping("/exists")
    public ResponseEntity<FcmTokenExistsResponse> checkFcmTokenExist(
            @AuthenticationPrincipal LoginUser loginUser,
            @NotBlank(message = "디바이스 아이디가 비어있습니다.")
            @RequestParam("deviceId") String deviceId
    ){
        return ResponseEntity.status(HttpStatus.OK).body(fcmTokenQueryService.checkFcmTokenExist(loginUser.getId(), deviceId));
    }

}
