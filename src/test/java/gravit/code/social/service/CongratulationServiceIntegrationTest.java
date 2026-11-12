package gravit.code.social.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.social.domain.Congratulation;
import gravit.code.social.repository.CongratulationRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.ALREADY_CONGRATULATED;
import static gravit.code.global.exception.domain.CustomErrorCode.CONGRATULATE_LIMIT_EXCEEDED;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
class CongratulationServiceIntegrationTest {

    @Autowired
    private CongratulationService congratulationService;

    @Autowired
    private CongratulationRepository congratulationRepository;

    @Nested
    @DisplayName("하루 축하 횟수를 확인하고 기록할 때")
    class CheckAndRecord {

        @Test
        void 첫_축하는_성공하고_기록된다() {
            // given & when
            congratulationService.checkAndRecord(1L, 2L, 999L);

            // then
            List<Congratulation> result = congratulationRepository.findAll();
            assertThat(result).hasSize(1);
            assertThat(result.get(0).getUserId()).isEqualTo(1L);
            assertThat(result.get(0).getActorId()).isEqualTo(2L);
            assertThat(result.get(0).getFeedId()).isEqualTo(999L);
        }

        @Test
        void 하루_3회_이내면_모두_성공한다() {
            // given & when
            congratulationService.checkAndRecord(1L, 2L, 1L);
            congratulationService.checkAndRecord(1L, 2L, 2L);
            congratulationService.checkAndRecord(1L, 2L, 3L);

            // then
            assertThat(congratulationRepository.findAll()).hasSize(3);
        }

        @Test
        void 하루_3회_초과시_예외가_발생한다() {
            // given
            congratulationService.checkAndRecord(1L, 2L, 1L);
            congratulationService.checkAndRecord(1L, 2L, 2L);
            congratulationService.checkAndRecord(1L, 2L, 3L);

            // when & then
            assertThatThrownBy(() -> congratulationService.checkAndRecord(1L, 2L, 4L))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(CONGRATULATE_LIMIT_EXCEEDED);
        }

        @Test
        void 다른_유저에게는_별도로_횟수가_카운트된다() {
            // given — actor 2에게 3회 축하
            congratulationService.checkAndRecord(1L, 2L, 1L);
            congratulationService.checkAndRecord(1L, 2L, 2L);
            congratulationService.checkAndRecord(1L, 2L, 3L);

            // when & then — actor 3에게는 처음이므로 성공
            congratulationService.checkAndRecord(1L, 3L, 4L);
            assertThat(congratulationRepository.findAll()).hasSize(4);
        }

        @Test
        void 동일_피드를_중복_축하하면_예외가_발생한다() {
            // given
            congratulationService.checkAndRecord(1L, 2L, 999L);

            // when & then
            assertThatThrownBy(() -> congratulationService.checkAndRecord(1L, 2L, 999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting("errorCode")
                    .isEqualTo(ALREADY_CONGRATULATED);
        }
    }
}
