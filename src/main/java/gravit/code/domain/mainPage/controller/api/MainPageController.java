package gravit.code.domain.mainPage.controller.api;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.mainPage.controller.docs.MainPageControllerSpecification;
import gravit.code.domain.mainPage.dto.response.MainPageResponse;
import gravit.code.domain.mainPage.facade.MainPageFacade;
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
