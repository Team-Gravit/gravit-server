package gravit.code.friend.service;


import gravit.code.friend.domain.Friend;
import gravit.code.friend.domain.FriendRepository;
import gravit.code.friend.dto.response.FollowCountsResponse;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.dto.response.FriendResponse;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.user.domain.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class FriendService {

    private static final int PAGE_SIZE = 10;
    private static final Sort FOLLOW_SORT = Sort.by(Sort.Order.desc("createdAt"));

    private final ApplicationEventPublisher publisher;
    private final FriendRepository friendRepository;
    private final UserRepository userRepository;

    @Transactional
    public FriendResponse following(
            long followerId,
            long followeeId
    ) {
        // 자기 자신에게 팔로잉 불가능
        if(followeeId == followerId){
            throw new RestApiException(CustomErrorCode.UNABLE_FOLLOWING_YOURSELF);
        }

        // 팔로잉 대상 유저가 존재하는지 확인
        userRepository.findById(followeeId)
                .orElseThrow(()-> new RestApiException(CustomErrorCode.FRIEND_NOT_FOUND));

        // 이미 팔로우 중인지 중복 체크
        if(friendRepository.existsByFollowerIdAndFolloweeId(followerId, followeeId)){
            throw new RestApiException(CustomErrorCode.FRIEND_CONFLICT);
        }

        Friend friend = Friend.create(followerId, followeeId);

        friendRepository.save(friend);

        publisher.publishEvent(new FollowMissionEvent(followerId));

        return FriendResponse.from(friend);
    }

    @Transactional
    public void unFollowing(
            long followerId,
            long followeeId
    ) {
        Optional<Friend> friend = friendRepository.findByFolloweeIdAndFollowerId(followeeId, followerId);

        // 만약 팔로우 한 내역이 존재하지 않는다면
        if(friend.isEmpty()){
            throw new RestApiException(CustomErrorCode.FRIEND_NOT_FOUND);
        }

        friendRepository.delete(friend.get());
    }

    @Transactional
    public void rejectFollowing(
            long followeeId,
            long followerId
    ) {
        Optional<Friend> friend = friendRepository.findByFolloweeIdAndFollowerId(followeeId, followerId);

        if(friend.isEmpty()){
            throw new RestApiException(CustomErrorCode.FRIEND_NOT_FOUND);
        }

        friendRepository.delete(friend.get());
    }

    @Transactional(readOnly = true)
    public SliceResponse<FollowerResponse> getFollowers(
            long followeeId,
            int page
    ) {
        Pageable pageable = friendPageable(page);
        Slice<FollowerResponse> responses = friendRepository.findFollowersByFolloweeId(followeeId, pageable);
        return SliceResponse.of(responses);
    }

    @Transactional(readOnly = true)
    public SliceResponse<FollowingResponse> getFollowings(
            long followerId,
            int page
    ) {
        Pageable pageable = friendPageable(page);
        Slice<FollowingResponse> responses = friendRepository.findFollowingsByFollowerId(followerId, pageable);
        return SliceResponse.of(responses);
    }

    private Pageable friendPageable(int page) {
        int safePage = Math.max(0, page);
        return PageRequest.of(safePage, PAGE_SIZE, FOLLOW_SORT);
    }

    @Transactional(readOnly = true)
    public FollowCountsResponse getFollowAndFollowingCounts(long userId){
        if(!userRepository.existsById(userId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        long followerCount = friendRepository.countByFolloweeId(userId);
        long followeeCount = friendRepository.countByFollowerId(userId);

        return new FollowCountsResponse(followerCount, followeeCount);
    }
}
