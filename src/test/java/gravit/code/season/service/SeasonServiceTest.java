//package gravit.code.season.service;
//
//import gravit.code.season.calendar.SeasonCalendar;
//import gravit.code.season.domain.Season;
//import gravit.code.season.domain.SeasonStatus;
//import gravit.code.season.infrastructure.SeasonRepository;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.Mock;
//import org.mockito.junit.jupiter.MockitoExtension;
//
//import java.time.Clock;
//import java.time.LocalDateTime;
//import java.time.OffsetDateTime;
//import java.time.ZoneId;
//import java.util.Optional;
//
//import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
//import static org.mockito.ArgumentMatchers.any;
//import static org.mockito.Mockito.when;
//
//@ExtendWith(MockitoExtension.class)
//class SeasonServiceTest {
//
//    @Mock
//    private SeasonRepository seasonRepository;
//
//    SeasonService seasonService;
//
//    @BeforeEach
//    void setUp(){
//        Clock fixedKst = Clock.fixed(
//                OffsetDateTime.parse("2025-08-05T12:34:56+09:00").toInstant(),
//                ZoneId.of("Asia/Seoul")
//        );
//
//        SeasonCalendar seasonCalendar = new SeasonCalendar(fixedKst);
//        seasonService = new SeasonService(seasonRepository, seasonCalendar);
//    }
//
//    @Test
//    void 만약_ACTIVE_인_Season이_존재한다면_해당_Season_리턴(){
//        // given
//        Season activeSeason = Season.active("2025-w32",
//                LocalDateTime.of(2025,8,4,0,0),
//                LocalDateTime.of(2025,8,11,0,0));
//
//        when(seasonRepository.findByStatus(SeasonStatus.ACTIVE)).thenReturn(Optional.of(activeSeason));
//
//        // when
//        Season result = seasonService.getOrCreateActiveSeason();
//
//        // then
//        assertThat(activeSeason.getStatus()).isEqualTo(SeasonStatus.ACTIVE);
//        assertThat(activeSeason.getSeasonKey()).isEqualTo("2025-w32");
//        assertThat(result.getStartsAt()).isEqualTo(LocalDateTime.of(2025,8,4,0,0));
//        assertThat(result.getEndsAt()).isEqualTo(LocalDateTime.of(2025,8,11,0,0));
//
//    }
//
//    @Test
//    void 만약_ACTIVE_인_Season이_없고_PREP_Season이_존재한다면_해당_Season_리턴(){
//        // given
//        Season prepSeason = Season.prep("2025-w33",
//                LocalDateTime.of(2025,8,11,0,0),
//                LocalDateTime.of(2025,8,18,0,0));
//
//        when(seasonRepository.findByStatus(SeasonStatus.ACTIVE)).thenReturn(Optional.empty());
//        when(seasonRepository.findByStatus(SeasonStatus.PREP)).thenReturn(Optional.of(prepSeason));
//
//        // when
//        Season result = seasonService.getOrCreateActiveSeason();
//
//        // then
//        assertThat(result.getStatus()).isEqualTo(SeasonStatus.PREP);
//        assertThat(result.getSeasonKey()).isEqualTo("2025-w33");
//        assertThat(result.getStartsAt()).isEqualTo(LocalDateTime.of(2025,8,11,0,0));
//        assertThat(result.getEndsAt()).isEqualTo(LocalDateTime.of(2025,8,18,0,0));
//
//    }
//
//    @Test
//    void ACTIVE_PREP_둘다_없고_FINALIZING_이_존재한다면_PREP_시즌_생성하고_리턴(){
//        // given
//        // 테스트 시 Clock 클래스는 "2025-08-05T12:34:56+09:00" 가 고정 값
//
//        when(seasonRepository.findByStatus(SeasonStatus.ACTIVE)).thenReturn(Optional.empty());
//        when(seasonRepository.findByStatus(SeasonStatus.PREP)).thenReturn(Optional.empty());
//        when(seasonRepository.existsByStatus(SeasonStatus.FINALIZING)).thenReturn(true);
//        when(seasonRepository.findBySeasonKey("2025-W33")).thenReturn(Optional.empty());
//
//        // 서비스 로직이 clock 값을 기반으로 만든 객체 리턴
//        when(seasonRepository.save(any(Season.class))).thenAnswer(inv -> inv.getArgument(0));
//
//        // when
//        Season result = seasonService.getOrCreateActiveSeason();
//
//        // then
//        assertThat(result.getStatus()).isEqualTo(SeasonStatus.PREP);
//        assertThat(result.getSeasonKey()).isEqualTo("2025-W33");
//        assertThat(result.getStartsAt()).isEqualTo(LocalDateTime.of(2025,8,11,0,0));
//        assertThat(result.getEndsAt()).isEqualTo(LocalDateTime.of(2025,8,18,0,0));
//    }
//
//    @Test
//    void FINALIZING_도_없다면_초기_시작이므로_ACTIVE_SEASON_생성하고_리턴(){
//        // given
//        when(seasonRepository.findByStatus(SeasonStatus.ACTIVE)).thenReturn(Optional.empty());
//        when(seasonRepository.findByStatus(SeasonStatus.PREP)).thenReturn(Optional.empty());
//        when(seasonRepository.existsByStatus(SeasonStatus.FINALIZING)).thenReturn(false);
//        when(seasonRepository.findBySeasonKey("2025-W32")).thenReturn(Optional.empty());
//
//        // 서비스 로직이 clock 값을 기반으로 만든 객체 리턴
//        when(seasonRepository.save(any(Season.class))).thenAnswer(inv -> inv.getArgument(0));
//
//        // when
//        Season result = seasonService.getOrCreateActiveSeason();
//
//        // then
//        assertThat(result.getStatus()).isEqualTo(SeasonStatus.ACTIVE);
//        assertThat(result.getSeasonKey()).isEqualTo("2025-W32");
//        assertThat(result.getStartsAt()).isEqualTo(LocalDateTime.of(2025,8,4,0,0));
//        assertThat(result.getEndsAt()).isEqualTo(LocalDateTime.of(2025,8,11,0,0));
//
//    }
//}