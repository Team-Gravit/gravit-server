//package gravit.code.season.batch;
//
//import gravit.code.global.exception.domain.RestApiException;
//import gravit.code.league.domain.League;
//import gravit.code.league.repository.LeagueRepository;
//import gravit.code.season.domain.Season;
//import gravit.code.season.domain.SeasonStatus;
//import gravit.code.season.infrastructure.SeasonRepository;
//import gravit.code.season.service.port.SeasonClosedCache;
//import gravit.code.userLeague.domain.UserLeagueRepository;
//import gravit.code.userLeagueHistory.infrastructure.UserLeagueHistoryRepository;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.ArgumentCaptor;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//import org.springframework.test.util.ReflectionTestUtils;
//
//import java.time.LocalDateTime;
//import java.util.Optional;
//
//import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
//import static org.junit.jupiter.api.Assertions.assertThrows;
//import static org.mockito.ArgumentMatchers.any;
//import static org.mockito.Mockito.*;
//
//@ExtendWith(MockitoExtension.class)
//class SeasonBatchServiceTest {
//
//    @Mock
//    SeasonRepository seasonRepository;
//
//    @Mock
//    UserLeagueHistoryRepository userLeagueHistoryRepository;
//
//    @Mock
//    UserLeagueRepository userLeagueRepository;
//
//    @Mock
//    LeagueRepository leagueRepository;
//
//    @Mock
//    SeasonClosedCache seasonClosedCache;
//
//    @InjectMocks
//    SeasonBatchService seasonBatchService;
//
//    @Test
//    void 활성_시즌을_닫고_히스토리_스냅샷_후_다음_시즌을_활성화_하고_UserLeague_를_롤오버한다(){
//        // given
//        Season nowSeason = Season.active("2025-W32", LocalDateTime.of(2025,8,5,0,0),LocalDateTime.of(2025,8,11,0,0));
//        Season newNextSeason = Season.prep("2025-W33", LocalDateTime.of(2025,8,  11,0,0),LocalDateTime.of(2025,8,18,0,0));
//        ReflectionTestUtils.setField(nowSeason, "id", 1L);
//        ReflectionTestUtils.setField(newNextSeason, "id", 2L);
//
//        doNothing().when(seasonClosedCache).setLastClosedSeasonId(any(Long.class));
//        when(seasonRepository.findCloseableActiveByNowForUpdate(any(LocalDateTime.class))).thenReturn(Optional.of(nowSeason));
//        when(userLeagueHistoryRepository.deleteBySeasonId(nowSeason)).thenReturn(12);
//        when(userLeagueHistoryRepository.insertFromCurrent(any(Long.class), any(LocalDateTime.class))).thenReturn(12);
//
//        /** prep 상태인 다음시즌이 존재하지 않는 상황 **/
//        when(seasonRepository.findPrepByStartingAt(newNextSeason.getStartsAt())).thenReturn(Optional.empty());
//        when(seasonRepository.save(any(Season.class))).thenReturn(newNextSeason);
//
//        League firstLeague = League.create("BRONZE 1", 100,0, 1);
//        when(leagueRepository.findFirstByOrderBySortOrderAsc()).thenReturn(Optional.of(firstLeague));
//        when(userLeagueRepository.resetAllForNextSeason(nowSeason,newNextSeason,firstLeague)).thenReturn(12);
//
//        // when
//        seasonBatchService.finalizeAndRolloverWeekly();
//
//        // then
//        assertThat(nowSeason.getStatus()).isEqualTo(SeasonStatus.CLOSED);
//        assertThat(newNextSeason.getStatus()).isEqualTo(SeasonStatus.ACTIVE);
//        verify(userLeagueHistoryRepository).insertFromCurrent(any(Long.class), any(LocalDateTime.class));
//
//        // findPrepStartingAtForUpdate 인자로 들어간 nextStartsAt이 nowSeason.endsAt 과 같은지 확인
//        ArgumentCaptor<LocalDateTime> startCapture = ArgumentCaptor.forClass(LocalDateTime.class);
//        verify(seasonRepository).findPrepByStartingAt(startCapture.capture());
//        assertThat(startCapture.getValue()).isEqualTo(newNextSeason.getStartsAt());
//
//        verify(seasonRepository, times(1)).save(any(Season.class));
//        verify(userLeagueRepository, times(1)).resetAllForNextSeason(nowSeason, newNextSeason, firstLeague);
//    }
//
//    @Test
//    void 다음_시즌이_이미_PREP_상태로_있으면_save_하지_않고_그_시즌을_활성화_한다(){
//        // given
//        Season nowSeason = Season.active("2025-W32", LocalDateTime.of(2025,8,5,0,0),LocalDateTime.of(2025,8,11,0,0));
//        Season nextSeason = Season.prep("2025-W33", LocalDateTime.of(2025,8,  11,0,0),LocalDateTime.of(2025,8,18,0,0));
//        ReflectionTestUtils.setField(nowSeason, "id", 1L);
//        ReflectionTestUtils.setField(nextSeason, "id", 2L);
//        doNothing().when(seasonClosedCache).setLastClosedSeasonId(any(Long.class));
//        when(seasonRepository.findCloseableActiveByNowForUpdate(any(LocalDateTime.class))).thenReturn(Optional.of(nowSeason));
//        when(userLeagueHistoryRepository.deleteBySeasonId(nowSeason)).thenReturn(12);
//        when(userLeagueHistoryRepository.insertFromCurrent(any(Long.class), any(LocalDateTime.class))).thenReturn(12);
//
//        /** PREP 인 다음 시즌이 존재함 **/
//        when(seasonRepository.findPrepByStartingAt(nextSeason.getStartsAt())).thenReturn(Optional.of(nextSeason));
//
//        League firstLeague = League.create("BRONZE 1", 100,0, 1);
//        when(leagueRepository.findFirstByOrderBySortOrderAsc()).thenReturn(Optional.of(firstLeague));
//        when(userLeagueRepository.resetAllForNextSeason(nowSeason, nextSeason, firstLeague)).thenReturn(12);
//
//        // when
//        seasonBatchService.finalizeAndRolloverWeekly();
//
//        // then
//        assertThat(nowSeason.getStatus()).isEqualTo(SeasonStatus.CLOSED);
//        assertThat(nextSeason.getStatus()).isEqualTo(SeasonStatus.ACTIVE);
//        verify(userLeagueHistoryRepository).insertFromCurrent(any(Long.class), any(LocalDateTime.class));
//
//        // findPrepStartingAtForUpdate 인자로 들어간 nextStartsAt이 nowSeason.endsAt 과 같은지 확인
//        ArgumentCaptor<LocalDateTime> startCapture = ArgumentCaptor.forClass(LocalDateTime.class);
//        verify(seasonRepository).findPrepByStartingAt(startCapture.capture());
//        assertThat(startCapture.getValue()).isEqualTo(nextSeason.getStartsAt());
//
//        verify(seasonRepository, times(0)).save(any(Season.class));
//        verify(userLeagueRepository, times(1)).resetAllForNextSeason(nowSeason, nextSeason, firstLeague);
//
//    }
//
//    @Test
//    void 배치_실행_시_활성_시즌이_없으면_예외를_던진다() {
//        // given
//        when(seasonRepository.findCloseableActiveByNowForUpdate(any(LocalDateTime.class))).thenReturn(Optional.empty());
//
//        // when
//        // then
//        assertThrows(RestApiException.class, ()-> seasonBatchService.finalizeAndRolloverWeekly());
//    }
//
//    @Test
//    void 리그가_없으면_예외를_던진다() {
//        // given
//        Season nowSeason = Season.active("2025-W32", LocalDateTime.of(2025,8,5,0,0),LocalDateTime.of(2025,8,11,0,0));
//        Season newNextSeason = Season.prep("2025-W33", LocalDateTime.of(2025,8,  11,0,0),LocalDateTime.of(2025,8,18,0,0));
//        ReflectionTestUtils.setField(nowSeason, "id", 1L);
//        ReflectionTestUtils.setField(newNextSeason, "id", 2L);
//
//        when(seasonRepository.findCloseableActiveByNowForUpdate(any(LocalDateTime.class))).thenReturn(Optional.of(nowSeason));
//        when(userLeagueHistoryRepository.deleteBySeasonId(nowSeason)).thenReturn(12);
//        when(userLeagueHistoryRepository.insertFromCurrent(any(Long.class), any(LocalDateTime.class))).thenReturn(12);
//
//        /** prep 상태인 다음시즌이 존재하지 않는 상황 **/
//        when(seasonRepository.findPrepByStartingAt(newNextSeason.getStartsAt())).thenReturn(Optional.empty());
//        when(seasonRepository.save(any(Season.class))).thenReturn(newNextSeason);
//
//        /** 리그가 존재하지 않을 때 **/
//        when(leagueRepository.findFirstByOrderBySortOrderAsc()).thenReturn(Optional.empty());
//
//        //when
//        //then
//        assertThrows(RestApiException.class, ()-> seasonBatchService.finalizeAndRolloverWeekly());
//    }
//}
