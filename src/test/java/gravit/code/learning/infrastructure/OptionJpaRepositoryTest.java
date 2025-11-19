//package gravit.code.learning.infrastructure;
//
//import gravit.code.learning.dto.response.OptionResponse;
//import gravit.code.learning.fixture.OptionFixture;
//import gravit.code.support.TCRepositoryTest;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.DisplayName;
//import org.junit.jupiter.api.Nested;
//import org.junit.jupiter.api.Test;
//import org.springframework.beans.factory.annotation.Autowired;
//
//import java.util.List;
//
//import static org.assertj.core.api.Assertions.assertThat;
//
//@TCRepositoryTest
//class OptionJpaRepositoryTest {
//
//    @Autowired
//    private OptionJpaRepository optionJpaRepository;
//
//    // problemIds
//    long problem1Id = 1L;
//    long problem2Id = 2L;
//    long problem3Id = 3L;
//
//    @BeforeEach
//    void setUp(){
//        optionJpaRepository.saveAll(List.of(
//                OptionFixture.정답_선지(problem1Id),
//                OptionFixture.오답_선지(problem1Id),
//                OptionFixture.오답_선지(problem1Id),
//                OptionFixture.오답_선지(problem1Id),
//
//                OptionFixture.정답_선지(problem2Id),
//                OptionFixture.오답_선지(problem2Id),
//                OptionFixture.오답_선지(problem2Id),
//                OptionFixture.오답_선지(problem2Id),
//
//                OptionFixture.정답_선지(problem3Id),
//                OptionFixture.오답_선지(problem3Id),
//                OptionFixture.오답_선지(problem3Id),
//                OptionFixture.오답_선지(problem3Id)
//        ));
//    }
//
//    @Nested
//    @DisplayName("여러 문제 아이디로 선지를 조회할 때")
//    class FindOptionsByProblemIds{
//
//        @Test
//        void 선지를_성공적으로_조회한다(){
//            //given
//            List<Long> validProblemIds = List.of(problem1Id, problem2Id, problem3Id);
//
//            //when
//            List<OptionResponse> optionResponses = optionJpaRepository.findAllByProblemIdInIds(validProblemIds);
//
//            //then
//            assertThat(optionResponses).hasSize(validProblemIds.size() * 4);
//
//            assertThat(optionResponses.get(0).optionId()).isEqualTo(1L);
//            assertThat(optionResponses.get(0).content()).isEqualTo("선지내용");
//
//            assertThat(optionResponses.get(1).optionId()).isEqualTo(2L);
//            assertThat(optionResponses.get(1).content()).isEqualTo("선지내용");
//        }
//
//        @Test
//        void 문제_아이디가_유효하지_않으면_빈_리스트를_반환한다(){
//            //given
//            List<Long> invalidProblemIds = List.of(999L, 9999L, 99999L);
//
//            //when
//            List<OptionResponse> optionResponses = optionJpaRepository.findAllByProblemIdInIds(invalidProblemIds);
//
//            //then
//            assertThat(optionResponses).isEmpty();
//        }
//    }
//
//    @Nested
//    @DisplayName("단일 문제 아이디로 선지를 조회할 때")
//    class FindOptionByProblemId{
//
//        @Test
//        void 선지를_성공적으로_조회한다(){
//            //given
//            long validProblemId = problem1Id;
//
//            //when
//            List<OptionResponse> optionResponses = optionJpaRepository.findByProblemId(validProblemId);
//
//            //then
//            assertThat(optionResponses).hasSize(4);
//
//            assertThat(optionResponses.get(0).optionId()).isEqualTo(1L);
//            assertThat(optionResponses.get(0).content()).isEqualTo("선지내용");
//
//            assertThat(optionResponses.get(1).optionId()).isEqualTo(2L);
//            assertThat(optionResponses.get(1).content()).isEqualTo("선지내용");
//        }
//
//        @Test
//        void 문제_아이디가_유효하지_않으면_빈_리스트를_반환한다(){
//            //given
//            long invalidProblemId = 999L;
//
//            //when
//            List<OptionResponse> optionResponses = optionJpaRepository.findByProblemId(invalidProblemId);
//
//            //then
//            assertThat(optionResponses).isEmpty();
//        }
//    }
//}
//
