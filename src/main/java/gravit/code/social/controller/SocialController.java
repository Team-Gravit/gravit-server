package gravit.code.social.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.social.controller.docs.SocialControllerDocs;
import gravit.code.social.dto.response.SocialFeedResponse;
import gravit.code.social.facade.SocialFacade;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/social")
@RequiredArgsConstructor
public class SocialController implements SocialControllerDocs {

    private final SocialFacade socialFacade;

    @GetMapping("/feed")
    public ResponseEntity<SliceResponse<SocialFeedResponse>> getFeed(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "0") int page
    ) {
        SliceResponse<SocialFeedResponse> feed = socialFacade.getFeed(loginUser.getId(), page);
        return ResponseEntity.ok(feed);
    }

    @DeleteMapping("/feed/{feedId}")
    public ResponseEntity<Void> hideFeed(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long feedId
    ) {
        socialFacade.hideFeed(loginUser.getId(), feedId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/feed/{feedId}/congratulate")
    public ResponseEntity<Void> congratulateFeed(
            @AuthenticationPrincipal LoginUser loginUser,
            @PathVariable long feedId
    ) {
        socialFacade.congratulateFeed(loginUser.getId(), feedId);
        return ResponseEntity.noContent().build();
    }
}
