package gravit.code.friend.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.friend.controller.docs.FriendControllerDocs;
import gravit.code.friend.dto.internal.SearchUserDto;
import gravit.code.friend.dto.response.FollowCountsResponse;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.dto.response.FriendResponse;
import gravit.code.friend.service.FriendService;
import gravit.code.global.dto.response.SliceResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static org.springframework.http.HttpStatus.OK;

@Slf4j
@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
public class FriendController implements FriendControllerDocs {

    private final FriendService friendService;

    @PostMapping("/following/{followeeId}")
    public ResponseEntity<FriendResponse> follow(
            @PathVariable("followeeId")Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        long followerId = loginUser.getId();
        FriendResponse friendResponse = friendService.follow(followerId, followeeId);
        return ResponseEntity.status(OK).body(friendResponse);
    }

    @PostMapping("/unfollowing/{followeeId}")
    public ResponseEntity<Void> unfollow(
            @PathVariable("followeeId")Long followeeId,
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        long userId = loginUser.getId();
        friendService.unfollow(userId, followeeId);
        return ResponseEntity.status(OK).build();
    }

    @PostMapping("/reject-following/{followerId}")
    public ResponseEntity<Void> rejectFollowing(
            @PathVariable("followerId") Long followerId,
            @AuthenticationPrincipal LoginUser loginUser
    ) {
        long userId = loginUser.getId();
        friendService.rejectFollowing(userId, followerId);
        return ResponseEntity.status(OK).build();
    }

    @GetMapping("/follower")
    public ResponseEntity<SliceResponse<FollowerResponse>> getFollowers(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "0") int page
    ){
        Long followeeId = loginUser.getId();
        SliceResponse<FollowerResponse> followers = friendService.getFollowers(followeeId, page);
        return ResponseEntity.status(OK).body(followers);
    }

    @GetMapping("/following")
    public ResponseEntity<SliceResponse<FollowingResponse>> getFollowings(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam(defaultValue = "0") int page
    ){
        Long followerId = loginUser.getId();
        SliceResponse<FollowingResponse> followings = friendService.getFollowings(followerId, page);
        return ResponseEntity.status(OK).body(followings);
    }

    @GetMapping("/count")
    public ResponseEntity<FollowCountsResponse> getFollowAndFollowingCount(@AuthenticationPrincipal LoginUser loginUser){
        long userId = loginUser.getId();
        FollowCountsResponse followAndFollowingCounts = friendService.getFollowAndFollowingCounts(userId);
        return ResponseEntity.status(OK).body(followAndFollowingCounts);
    }

    @GetMapping("/search")
    public ResponseEntity<SliceResponse<SearchUserDto>> search(
            @AuthenticationPrincipal LoginUser loginUser,
            @RequestParam String queryText,
            @RequestParam(defaultValue = "0") int page
    ){
        SliceResponse<SearchUserDto> pageResponse = friendService.searchUsersForFollowing(loginUser.getId(), queryText, page);
        return ResponseEntity.status(OK).body(pageResponse);
    }
}
