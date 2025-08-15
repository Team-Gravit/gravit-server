package gravit.code.domain.friend.controller;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.friend.controller.docs.FriendSearchControllerDocs;
import gravit.code.domain.friend.dto.response.PageSearchUserResponse;
import gravit.code.domain.friend.service.FriendSearchService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/v1/friends/search")
@RequiredArgsConstructor
public class FriendSearchController implements FriendSearchControllerDocs {

    private final FriendSearchService friendSearchService;

    @GetMapping
    public ResponseEntity<PageSearchUserResponse> search(@AuthenticationPrincipal LoginUser loginUser,
                                                         @RequestParam String handleQuery,
                                                         @RequestParam(defaultValue = "0") int page){
        PageSearchUserResponse pageSearchUserResponse = friendSearchService.searchUsersForFollowing(loginUser.getId(), handleQuery, page);
        return ResponseEntity.ok(pageSearchUserResponse);
    }

}
