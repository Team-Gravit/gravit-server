package gravit.code.learning.infrastructure;

import gravit.code.learning.domain.Option;
import gravit.code.learning.dto.response.OptionResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@ActiveProfiles("test")
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class OptionRepositoryImplTest {

    @Autowired
    private OptionJpaRepository optionJpaRepository;

    @BeforeEach
    void setUp() {
        Option option1 = Option.create(
                "ArrayList는 동적 배열이다",
                "ArrayList는 크기가 가변적인 동적 배열 구조이다",
                true,
                1L
        );
        
        Option option2 = Option.create(
                "ArrayList는 정적 배열이다",
                "ArrayList는 동적으로 크기가 변하므로 정적 배열이 아니다",
                false,
                1L
        );

        Option option3 = Option.create(
                "LinkedList는 순차 접근만 가능하다",
                "LinkedList는 인덱스를 통한 랜덤 접근이 가능하지만 비효율적이다",
                false,
                2L
        );

        Option option4 = Option.create(
                "LinkedList는 노드 기반 구조이다",
                "LinkedList는 각 노드가 다음 노드를 참조하는 구조이다",
                true,
                2L
        );

        Option option5 = Option.create(
                "HashMap의 시간복잡도는 O(1)이다",
                "평균적으로 HashMap의 조회, 삽입, 삭제는 O(1) 시간복잡도를 가진다",
                true,
                3L
        );

        Option option6 = Option.create(
                "HashMap의 시간복잡도는 O(log n)이다",
                "HashMap은 해시 테이블 기반으로 O(1) 평균 시간복잡도를 가진다",
                false,
                3L
        );

        Option option7 = Option.create(
                "Stack은 LIFO 구조이다",
                "Stack은 Last In First Out 구조로 마지막에 들어간 요소가 먼저 나온다",
                true,
                4L
        );

        Option option8 = Option.create(
                "Stack은 FIFO 구조이다",
                "Stack은 LIFO이고, FIFO는 Queue의 특성이다",
                false,
                4L
        );

        Option option9 = Option.create(
                "Queue는 FIFO 구조이다",
                "Queue는 First In First Out 구조로 먼저 들어간 요소가 먼저 나온다",
                true,
                5L
        );

        Option option10 = Option.create(
                "Queue는 LIFO 구조이다",
                "Queue는 FIFO이고, LIFO는 Stack의 특성이다",
                false,
                5L
        );

        List<Option> options = List.of(
                option1, option2, option3, option4, option5,
                option6, option7, option8, option9, option10
        );
        optionJpaRepository.saveAll(options);
    }

    @Nested
    @DisplayName("OptionResponse 리스트를 조회할 때,")
    class FindOptionResponses{

        @Test
        @DisplayName("주어진 problemIds가 유효하면 problemId에 해당하는 선지를 반환한다.")
        void withValidProblemIds(){
            //given
            List<Long> problemIds = List.of(1L, 2L, 3L, 4L, 5L);

            //when
            List<OptionResponse> optionResponses = optionJpaRepository.findAllByProblemIdInIds(problemIds);

            //then
            assertThat(optionResponses).hasSize(10);
        }

        @Test
        @DisplayName("주어진 problemIds가 유효하지 않다면 빈 리스트를 반환한다.")
        void withInvalidProblemIds(){
            //given
            List<Long> problemIds = List.of(6L, 7L, 8L, 9L, 10L);

            //when
            List<OptionResponse> optionResponses = optionJpaRepository.findAllByProblemIdInIds(problemIds);

            //then
            assertThat(optionResponses).isEmpty();
        }
    }
}