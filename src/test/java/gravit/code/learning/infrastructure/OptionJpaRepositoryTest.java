package gravit.code.learning.infrastructure;

import gravit.code.global.config.RepositoryTest;
import gravit.code.learning.domain.Option;
import gravit.code.learning.dto.response.OptionResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@RepositoryTest
class OptionJpaRepositoryTest {

    @Autowired
    private OptionJpaRepository optionJpaRepository;

    // problemIds
    long problem1Id = 1L;
    long problem2Id = 2L;
    long problem3Id = 3L;

    @BeforeEach
    void saveOptions(){

        Option option1 = Option.create("content1", "explanation1", true, problem1Id);
        Option option2 = Option.create("content2", "explanation2", false, problem1Id);
        Option option3 = Option.create("content3", "explanation3", false, problem1Id);
        Option option4 = Option.create("content4", "explanation4", false, problem1Id);

        Option option5 = Option.create("content5", "explanation5", true, problem2Id);
        Option option6 = Option.create("content6", "explanation6", false, problem2Id);
        Option option7 = Option.create("content7", "explanation7", false, problem2Id);
        Option option8 = Option.create("content8", "explanation8", false, problem2Id);

        Option option9 = Option.create("content9", "explanation9", true, problem3Id);
        Option option10 = Option.create("content10", "explanation10", false, problem3Id);
        Option option11 = Option.create("content11", "explanation11", false, problem3Id);
        Option option12 = Option.create("content12", "explanation12", false, problem3Id);

        List<Option> dummyOptions = List.of(
                option1, option2, option3, option4,
                option5, option6, option7, option8,
                option9, option10, option11, option12
        );

        optionJpaRepository.saveAll(dummyOptions);
    }

    @Nested
    @DisplayName("problemId로 Option을 조회할 때")
    class FindOptions{

        @Test
        @DisplayName("problemId가 유효하면 정상적으로 Option을 조회한다.")
        void withValidProblemId(){
            //given
            List<Long> validProblemIds = List.of(problem1Id, problem2Id, problem3Id);

            //when
            List<OptionResponse> optionResponses = optionJpaRepository.findAllByProblemIdInIds(validProblemIds);

            //then
            assertThat(optionResponses).hasSize(validProblemIds.size() * 4);

            assertThat(optionResponses.get(0).optionId()).isEqualTo(1L);
            assertThat(optionResponses.get(0).content()).isEqualTo("content1");

            assertThat(optionResponses.get(1).optionId()).isEqualTo(2L);
            assertThat(optionResponses.get(1).content()).isEqualTo("content2");
        }

        @Test
        @DisplayName("problemId가 유효하지 않으면 빈 리스트를 반환한다.")
        void withInvalidProblemId(){
            //given
            List<Long> invalidProblemIds = List.of(999L, 9999L, 99999L);

            //when
            List<OptionResponse> optionResponses = optionJpaRepository.findAllByProblemIdInIds(invalidProblemIds);

            //then
            assertThat(optionResponses).isEmpty();
        }
    }
}
