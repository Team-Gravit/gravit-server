package gravit.code.domain.progress.domain;

import gravit.code.domain.learning.domain.Unit;
import gravit.code.domain.learning.infrastructure.UnitJpaRepository;
import gravit.code.domain.progress.dto.response.UnitProgressDetailResponse;
import gravit.code.domain.progress.infrastructure.UnitProgressJpaRepository;
import gravit.code.domain.user.domain.User;
import gravit.code.domain.user.infrastructure.UserJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@ActiveProfiles("test")
class UnitProgressRepositoryTest {

    @Autowired
    private UserJpaRepository userRepository;

    @Autowired
    private UnitProgressJpaRepository unitProgressRepository;

    @Autowired
    private UnitJpaRepository unitRepository;

    @BeforeEach
    void setUp() {

        User user = User.create("이메일", "프로바이더 아이디", "닉네임", "핸들", 1, LocalDateTime.now());
        userRepository.save(user);

        Unit unit1 = Unit.create("유닛1", 10L, 1L);
        Unit unit2 = Unit.create("유닛2", 10L, 1L);
        Unit unit3 = Unit.create("유닛3", 10L, 1L);

        unitRepository.saveAll(List.of(unit1, unit2, unit3));

        UnitProgress unitProgress1 = UnitProgress.create(10L, user.getId(), unit1.getId());
        UnitProgress unitProgress2 = UnitProgress.create(10L, user.getId(), unit2.getId());

        unitProgressRepository.saveAll(List.of(unitProgress1, unitProgress2));
    }

    @Nested
    @DisplayName("UnitProgressDetail을 조회할 때,")
    class FindUnitProgressDetail{

        @Test
        @DisplayName("userId가 유효하지 않으면 빈 리스트를 반환한다.")
        void withInvalidUserId(){
            //given
            Long userId = 999L;
            Long chapterId = 1L;

            //when
            List<UnitProgressDetailResponse> unitProgressDetailResponse = unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId);

            //then
            assertThat(unitProgressDetailResponse).isEmpty();
        }

        @Test
        @DisplayName("userId가 유효하면 정상적으로 반환한다.")
        void withValidUserId(){
            //given
            Long userId = 1L;
            Long chapterId = 1L;

            //when
            List<UnitProgressDetailResponse> unitProgressDetailResponse = unitProgressRepository.findAllUnitProgressDetailsByChapterIdAndUserId(chapterId, userId);

            //then
            assertThat(unitProgressDetailResponse).hasSize(3);
            assertThat(unitProgressDetailResponse.get(2).completedLesson()).isZero();
        }
    }
}