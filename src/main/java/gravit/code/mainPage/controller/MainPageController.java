package gravit.code.mainPage.controller;

import gravit.code.mainPage.dto.response.MainPageResponse;
import gravit.code.mainPage.facade.MainPageFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/home")
@RequiredArgsConstructor
public class MainPageController {

    private final MainPageFacade mainPageFacade;

    @GetMapping("/{userId}")
    public ResponseEntity<MainPageResponse> getMainPage(@PathVariable Long userId){
        return ResponseEntity.status(HttpStatus.OK).body(mainPageFacade.getMainPage(userId));
    }
}
