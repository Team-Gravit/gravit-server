package gravit.code.progress.domain;

import gravit.code.learning.domain.Chapter;
import gravit.code.learning.infrastructure.ChapterJpaRepository;
import gravit.code.progress.dto.response.ChapterProgressDetailResponse;
import gravit.code.progress.infrastructure.ChapterProgressJpaRepository;
import gravit.code.progress.domain.ChapterProgress;
import gravit.code.user.domain.Role;
import gravit.code.user.domain.User;
import gravit.code.user.infrastructure.UserJpaRepository;
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
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
@ActiveProfiles("test")
class ChapterProgressRepositoryTest {

    @Autowired
    private UserJpaRepository userRepository;

    @Autowired
    private ChapterProgressJpaRepository chapterProgressJpaRepository;

    @Autowired
    private ChapterJpaRepository chapterJpaRepository;

    @BeforeEach
    void setUp() {
        User user = User.create("이메일", "프로바이더 아이디", "닉네임", "핸들", 1, Role.USER);
        userRepository.save(user);

        Chapter chapter1 = Chapter.create("자료구조", "스택, 큐, 트리, 그래프 등 기본적인 자료구조의 개념과 구현을 학습합니다.", 8L);
        chapterJpaRepository.save(chapter1);

        Chapter chapter2 = Chapter.create("알고리즘", "정렬, 탐색, 동적계획법 등 핵심 알고리즘의 원리와 적용을 학습합니다.", 10L);
        chapterJpaRepository.save(chapter2);

        Chapter chapter3 = Chapter.create("데이터베이스", "관계형 데이터베이스의 설계, SQL 쿼리, 트랜잭션 관리를 학습합니다.", 7L);
        chapterJpaRepository.save(chapter3);

        Chapter chapter4 = Chapter.create("네트워크", "TCP/IP, HTTP, 소켓 프로그래밍 등 네트워크 기초를 학습합니다.", 6L);
        chapterJpaRepository.save(chapter4);

        ChapterProgress chapterProgress1 = ChapterProgress.create(10L, user.getId(), chapter1.getId());
        chapterProgressJpaRepository.save(chapterProgress1);
        chapterProgress1.updateCompletedUnits();

        ChapterProgress chapterProgress2 = ChapterProgress.create(11L, user.getId(), chapter2.getId());
        chapterProgressJpaRepository.save(chapterProgress2);

        ChapterProgress chapterProgress3 = ChapterProgress.create(12L, user.getId(), chapter3.getId());
        chapterProgressJpaRepository.save(chapterProgress3);

        // Chapter4는 진행하지 않은 상태
    }


    @Nested
    @DisplayName("ChapterProgress를 조회할 때,")
    class FindChapterProgress{

        @Test
        @DisplayName("chapterId와 userId가 유효하면 ChapterProgress를 반환한다.")
        void withValidChapterIdAndUserId(){
            //given
            long userId = 1L;
            long chapterId = 1L;

            //when
            Optional<ChapterProgress> chapterProgress = chapterProgressJpaRepository.findByChapterIdAndUserId(chapterId, userId);

            //then
            assertThat(chapterProgress).isPresent();
            assertThat(chapterProgress.get().getChapterId()).isEqualTo(chapterId);
            assertThat(chapterProgress.get().getUserId()).isEqualTo(userId);
        }

        @Test
        @DisplayName("chapterId와 userId가 유효하지 않으면 Optional.empty()를 반환한다.")
        void withInvalidChapterIdAndUserId(){
            //given
            long userId = 999L;
            long chapterId = 999L;

            //when
            Optional<ChapterProgress> chapterProgress = chapterProgressJpaRepository.findByChapterIdAndUserId(chapterId, userId);

            //then
            assertThat(chapterProgress).isNotPresent();
        }

    }

    @Nested
    @DisplayName("ChapterProgressDetail을 조회할 때,")
    class FindChapterProgressDetail{

        @Test
        @DisplayName("userId가 유효하면 정상적으로 반환한다.")
        void withValidUserId(){
            //given
            long userId = 1L;

            //when
            List<ChapterProgressDetailResponse> chapterProgressDetailResponses = chapterProgressJpaRepository.findAllChapterProgressDetailByUserId(userId);

            //then
            assertThat(chapterProgressDetailResponses).hasSize(4);
            assertThat(chapterProgressDetailResponses.get(0).chapterId()).isEqualTo(1L);
            assertThat(chapterProgressDetailResponses.get(0).completedUnits()).isEqualTo(1L);
            assertThat(chapterProgressDetailResponses.get(3).completedUnits()).isEqualTo(0L);
        }

        @Test
        @DisplayName("userId가 유효하지 않으면 빈 리스트를 반환한다.")
        void withInvalidUserId(){
            //given
            long userId = 999L;

            //when
            List<ChapterProgressDetailResponse> chapterProgressDetailResponses = chapterProgressJpaRepository.findAllChapterProgressDetailByUserId(userId);

            //then
            assertThat(chapterProgressDetailResponses).hasSize(0);
        }
    }
}