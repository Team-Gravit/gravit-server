package gravit.code.domain.friend.presentation;

import gravit.code.auth.oauth.LoginUser;
import gravit.code.domain.friend.application.FriendService;
import gravit.code.domain.friend.application.dto.response.FriendResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @PostMapping("/following/{followeeId}")
    public ResponseEntity<FriendResponse> following(@PathVariable("followeeId")Long followeeId,
                                                    @AuthenticationPrincipal LoginUser loginUser) {
        Long followerId = loginUser.getId();
        log.info("[following] followerId : {} , followeeId : {}", followerId, followeeId);
        FriendResponse friendResponse = friendService.following(loginUser.getId(), followeeId);
        return ResponseEntity.ok(friendResponse);
    }

    @PostMapping("/unfollowing/{followeeId}")
    public ResponseEntity<String> unFollowing(@PathVariable("followeeId")Long followeeId,
                                              @AuthenticationPrincipal LoginUser loginUser) {
        friendService.unFollowing(followeeId, loginUser.getId());
        return ResponseEntity.ok("팔로우를 성공적으로 취소하였습니다. followeeId = " + followeeId);
    }

}
