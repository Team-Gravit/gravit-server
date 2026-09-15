package gravit.code.user.controller;

import gravit.code.auth.domain.LoginUser;
import gravit.code.dailyLearningRecord.domain.DailyLearningRecord;
import gravit.code.dailyLearningRecord.repository.DailyLearningRecordRepository;
import gravit.code.learning.fixture.LearningFixture;
import gravit.code.learning.repository.LearningRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@TCSpringBootTest
@AutoConfigureMockMvc
class MainPageControllerIntegrationTest {

    private static final String WEEKLY_RECORD_URI = "/api/v1/main-pages/weekly-record";
    private static final long USER_ID = 1L;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private LearningRepository learningRepository;

    @Autowired
    private DailyLearningRecordRepository dailyLearningRecordRepository;

    @Autowired
    private Clock clock;

    private RequestPostProcessor 유저_인증() {
        LoginUser user = new LoginUser(
                USER_ID,
                "test",
                null,
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        return authentication(new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities()));
    }

    @Nested
    @DisplayName("주간 학습 기록을 조회할 때")
    class GetWeeklyRecord {

        @Test
        void 요일마다_시점과_학습_완료_여부를_반환한다() throws Exception {
            // given
            learningRepository.save(LearningFixture.저장_전_학습(USER_ID, false, 3));

            LocalDate monday = LocalDate.now(clock).with(DayOfWeek.MONDAY);
            dailyLearningRecordRepository.save(DailyLearningRecord.create(USER_ID, monday));

            // when & then
            mockMvc.perform(get(WEEKLY_RECORD_URI).with(유저_인증()))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.consecutiveSolvedDays").value(3))
                    .andExpect(jsonPath("$.MONDAY.dayTiming").value("PAST"))
                    .andExpect(jsonPath("$.MONDAY.isCompleted").value(true))
                    .andExpect(jsonPath("$.TUESDAY.dayTiming").value("TODAY"))
                    .andExpect(jsonPath("$.TUESDAY.isCompleted").value(false))
                    .andExpect(jsonPath("$.WEDNESDAY.dayTiming").value("FUTURE"))
                    .andExpect(jsonPath("$.WEDNESDAY.isCompleted").value(false));
        }
    }
}
