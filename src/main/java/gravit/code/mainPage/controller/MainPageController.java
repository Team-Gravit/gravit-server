package gravit.code.mainPage.controller;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.mainPage.controller.docs.MainPageControllerSpecification;
import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.mainPage.facade.MainPageFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/main")
@RequiredArgsConstructor
public class MainPageController implements MainPageControllerSpecification {

    private final MainPageFacade mainPageFacade;

    @GetMapping
    public ResponseEntity<MainPageResponse> getMainPage(@AuthenticationPrincipal LoginUser loginUser){
        return ResponseEntity.status(HttpStatus.OK).body(mainPageFacade.getMainPage(loginUser.getId()));
    }
}
