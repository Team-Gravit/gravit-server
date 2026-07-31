package gravit.code.userLeague.service;

import gravit.code.global.dto.response.SliceResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.season.domain.SeasonStatus;
import gravit.code.season.repository.SeasonRepository;
import gravit.code.user.repository.UserRepository;
import gravit.code.userLeague.dto.internal.LeagueRankEntry;
import gravit.code.userLeague.dto.internal.LeagueRankProfileDto;
import gravit.code.userLeague.dto.internal.LeagueRankRowDto;
import gravit.code.userLeague.dto.internal.MyLeagueProfileDto;
import gravit.code.userLeague.dto.response.MyLeagueRankWithProfileResponse;
import gravit.code.userLeague.repository.UserLeagueRepository;
import gravit.code.userLeague.support.LeagueRankFinder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Slf4j
@RequiredArgsConstructor
@Service
public class UserLeagueQueryService {

    private static final int PAGE_SIZE = 10;
    private static final int NEXT_PAGE_PROBE = 1;
    private static final int FIRST_PAGE = 0;

    private final UserRepository userRepository;
    private final UserLeagueRepository userLeagueRepository;
    private final SeasonRepository seasonRepository;

    private final LeagueRankFinder leagueRankFinder;

    @Transactional(readOnly = true)
    public MyLeagueRankWithProfileResponse getMyLeagueRankWithProfile(long userId) {

        if(!userRepository.existsById(userId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        MyLeagueProfileDto profile = userLeagueRepository.findLeagueProfile(userId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.USER_LEAGUE_NOT_FOUND));

        int rank = leagueRankFinder.findRank(
                profile.seasonId(),
                profile.leagueId(),
                profile.userId(),
                profile.lp()
        );

        return toMyLeagueRankWithProfile(profile, rank);
    }

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRowDto> findLeagueRanking(
            long leagueId,
            int page
    ){
        int safePage = Math.max(FIRST_PAGE, page);

        return seasonRepository.findByStatus(SeasonStatus.ACTIVE)
                .map(season -> findRankingPage(season.getId(), leagueId, safePage))
                .orElseGet(SliceResponse::empty);
    }

    @Transactional(readOnly = true)
    public SliceResponse<LeagueRankRowDto> findLeagueRankingByUser(
            long userId,
            int page
    ){
        int safePage = Math.max(FIRST_PAGE, page);

        if(!userRepository.existsById(userId)){
            throw new RestApiException(CustomErrorCode.USER_NOT_FOUND);
        }

        return userLeagueRepository.findLeagueProfile(userId)
                .map(profile -> findRankingPage(profile.seasonId(), profile.leagueId(), safePage))
                .orElseGet(SliceResponse::empty);
    }

    private SliceResponse<LeagueRankRowDto> findRankingPage(
            long seasonId,
            long leagueId,
            int safePage
    ) {
        List<LeagueRankEntry> entries = leagueRankFinder.findPage(
                seasonId,
                leagueId,
                safePage * PAGE_SIZE,
                PAGE_SIZE + NEXT_PAGE_PROBE
        );

        boolean hasNextPage = entries.size() > PAGE_SIZE;
        List<LeagueRankEntry> pageEntries = hasNextPage ? entries.subList(FIRST_PAGE, PAGE_SIZE) : entries;

        List<LeagueRankRowDto> contents = toRankRows(pageEntries);

        if (contents.isEmpty()) {
            return SliceResponse.empty();
        }

        return SliceResponse.of(hasNextPage, contents);
    }

    private List<LeagueRankRowDto> toRankRows(List<LeagueRankEntry> entries) {
        if (entries.isEmpty()) {
            return List.of();
        }

        List<Long> userIds = entries.stream()
                .map(LeagueRankEntry::userId)
                .toList();

        Map<Long, LeagueRankProfileDto> profiles = userLeagueRepository.findRankProfilesByUserIds(userIds).stream()
                .collect(Collectors.toMap(LeagueRankProfileDto::userId, Function.identity()));

        return entries.stream()
                .filter(entry -> profiles.containsKey(entry.userId()))
                .map(entry -> toRankRow(entry, profiles.get(entry.userId())))
                .toList();
    }

    private LeagueRankRowDto toRankRow(
            LeagueRankEntry entry,
            LeagueRankProfileDto profile
    ) {
        return new LeagueRankRowDto(
                entry.rank(),
                entry.userId(),
                entry.leaguePoint(),
                profile.nickname(),
                profile.profileImgNumber(),
                profile.xp(),
                profile.level()
        );
    }

    private MyLeagueRankWithProfileResponse toMyLeagueRankWithProfile(
            MyLeagueProfileDto profile,
            int rank
    ) {
        return new MyLeagueRankWithProfileResponse(
                profile.leagueId(),
                profile.leagueName(),
                rank,
                profile.userId(),
                profile.lp(),
                profile.maxLp(),
                profile.nickname(),
                profile.profileImgNumber(),
                profile.xp(),
                profile.level()
        );
    }
}
