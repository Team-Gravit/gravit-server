package gravit.code.friend.controller;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.friend.controller.docs.FriendSearchControllerDocs;
import gravit.code.friend.dto.SearchUser;
import gravit.code.friend.service.FriendSearchService;
import gravit.code.global.dto.SliceResponse;
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
    public ResponseEntity<SliceResponse<SearchUser>> search(@AuthenticationPrincipal LoginUser loginUser,
                                                            @RequestParam String queryText,
                                                            @RequestParam(defaultValue = "0") int page){
        SliceResponse<SearchUser> pageResponse = friendSearchService.searchUsersForFollowing(loginUser.getId(), queryText, page);
        return ResponseEntity.ok(pageResponse);
    }

}
