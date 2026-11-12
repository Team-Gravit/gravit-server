package gravit.code.friend.service;

import gravit.code.friend.domain.Friend;
import gravit.code.friend.dto.event.FollowedEvent;
import gravit.code.friend.dto.internal.SearchUserDto;
import gravit.code.friend.dto.response.FollowCountsResponse;
import gravit.code.friend.dto.response.FollowerResponse;
import gravit.code.friend.dto.response.FollowingResponse;
import gravit.code.friend.dto.response.FriendResponse;
import gravit.code.friend.repository.FriendRepository;
import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.mission.dto.event.FollowMissionEvent;
import gravit.code.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.Set;

import static gravit.code.global.exception.domain.CustomErrorCode.FRIEND_CONFLICT;
import static gravit.code.global.exception.domain.CustomErrorCode.FRIEND_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.UNABLE_FOLLOWING_YOURSELF;

@Slf4j
@Service
@RequiredArgsConstructor
public class FriendService {

    private static final int PAGE_SIZE = 10;
    private static final Sort FOLLOW_SORT = Sort.by(Sort.Order.desc("createdAt"));

    private final FriendRepository friendRepository;
    private final UserRepository userRepository;

    private final ApplicationEventPublisher publisher;

    @Transactional
    public FriendResponse follow(
            long followerId,
            long followeeId
    ) {
        if(followeeId == followerId){
            throw new RestApiException(UNABLE_FOLLOWING_YOURSELF);
        }

        userRepository.findById(followeeId)
                .orElseThrow(()-> new RestApiException(FRIEND_NOT_FOUND));

        if(friendRepository.existsByFollowerIdAndFolloweeId(followerId, followeeId)){
            throw new RestApiException(FRIEND_CONFLICT);
        }

        Friend friend = Friend.create(followerId, followeeId);

        friendRepository.save(friend);

        publisher.publishEvent(new FollowMissionEvent(followerId));
        publisher.publishEvent(new FollowedEvent(followerId, followeeId));

        return FriendResponse.from(friend);
    }

    @Transactional
    public void unfollow(
            long followerId,
            long followeeId
    ) {
        Optional<Friend> friend = friendRepository.findByFolloweeIdAndFollowerId(followeeId, followerId);

        if(friend.isEmpty()){
            throw new RestApiException(FRIEND_NOT_FOUND);
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
            throw new RestApiException(FRIEND_NOT_FOUND);
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
        long followerCount = friendRepository.countByFolloweeId(userId);
        long followeeCount = friendRepository.countByFollowerId(userId);

        return FollowCountsResponse.of(followerCount, followeeCount);
    }

    @Transactional(readOnly = true)
    public List<Long> getFollowerIds(long followeeId) {
        return friendRepository.findFollowerIdsByFolloweeId(followeeId);
    }

    @Transactional(readOnly = true)
    public Set<Long> findFollowingIdsAmong(
            long followerId,
            Set<Long> followeeIds
    ) {
        return friendRepository.findFollowingIdsAmong(followerId, followeeIds);
    }

    @Transactional(readOnly = true)
    public SliceResponse<SearchUserDto> searchUsersForFollowing(
            Long requesterId,
            String queryText,
            int page
    ){
        int safePage = Math.max(0, page);
        return friendRepository.searchUsersByQueryText(requesterId, queryText, safePage);
    }
}
