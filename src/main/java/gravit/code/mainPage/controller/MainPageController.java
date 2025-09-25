package gravit.code.mainPage.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.mainPage.controller.docs.MainPageControllerDocs;
import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/main")
public class MainPageController implements MainPageControllerDocs {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<MainPageResponse> getMainPage(@AuthenticationPrincipal LoginUser loginUser){
        return ResponseEntity.status(HttpStatus.OK).body(userService.getMainPage(loginUser.getId()));
    }
}
