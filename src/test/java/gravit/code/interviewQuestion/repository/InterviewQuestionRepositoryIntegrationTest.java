package gravit.code.interviewQuestion.repository;

import gravit.code.interviewQuestion.domain.InterviewDifficulty;
import gravit.code.interviewQuestion.domain.InterviewQuestion;
import gravit.code.interviewQuestion.domain.InterviewTopic;
import gravit.code.interviewQuestion.fixture.InterviewQuestionFixture;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.test.util.ReflectionTestUtils;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
class InterviewQuestionRepositoryIntegrationTest {

    private static final String AUDIO_KEY_FIELD = "audioKey";
    private static final String AUDIO_KEY = "interview-question/1.mp3";
    private static final String AUDIO_KEY_FORMAT = "interview-question/%d.mp3";
    private static final String INTERVIEW_SEED_LOCATION = "classpath*:sql/interview/**/*.sql";
    private static final int SEED_FILE_COUNT = 263;
    private static final int SEED_QUESTION_COUNT = 1315;
    // 음성이 만들어진 마지막 면접 질문 id. 이후 질문(#619 추가분)은 음성을 백필하기 전까지 audio_key가 비어 있다.
    // 백필하면 이 상수와 음성 미생성 검증을 지우고 모든 질문에 음성 키를 요구한다.
    private static final long LAST_VOICED_QUESTION_ID = 1135L;

    @Autowired
    private InterviewQuestionRepository interviewQuestionRepository;

    @Autowired
    private DataSource dataSource;

    @Nested
    @DisplayName("음성 키를 저장하고 조회할 때")
    class AudioKey {

        @Test
        void 음성_키를_저장하고_다시_읽는다() {
            // given
            InterviewQuestion question = InterviewQuestionFixture.문제(InterviewTopic.DATA_STRUCTURE, InterviewDifficulty.EASY);
            ReflectionTestUtils.setField(question, AUDIO_KEY_FIELD, AUDIO_KEY);
            Long id = interviewQuestionRepository.save(question).getId();

            // when
            InterviewQuestion found = interviewQuestionRepository.findById(id).orElseThrow();

            // then
            assertThat(found.getAudioKey()).isEqualTo(AUDIO_KEY);
        }

        @Test
        void 음성_키가_없는_문제는_null로_읽힌다() {
            // given
            InterviewQuestion question = InterviewQuestionFixture.문제(InterviewTopic.DATA_STRUCTURE, InterviewDifficulty.EASY);
            Long id = interviewQuestionRepository.save(question).getId();

            // when
            InterviewQuestion found = interviewQuestionRepository.findById(id).orElseThrow();

            // then
            assertThat(found.getAudioKey()).isNull();
        }
    }

    @Nested
    @DisplayName("면접 시드 SQL을 적재할 때")
    class Seed {

        @Test
        void 음성이_만들어진_문제에는_문제_id로_만든_음성_키가_들어간다() {
            // given
            Resource[] seeds = 면접_시드를_적재한다();

            // when
            List<InterviewQuestion> questions = interviewQuestionRepository.findAll();

            // then
            assertSoftly(softly -> {
                softly.assertThat(seeds).hasSize(SEED_FILE_COUNT);
                softly.assertThat(questions).hasSize(SEED_QUESTION_COUNT);
                softly.assertThat(questions)
                        .filteredOn(question -> question.getId() <= LAST_VOICED_QUESTION_ID)
                        .isNotEmpty()
                        .allSatisfy(question ->
                                assertThat(question.getAudioKey()).isEqualTo(AUDIO_KEY_FORMAT.formatted(question.getId())));
            });
        }

        @Test
        void 음성_백필_전인_문제는_음성_키가_비어_있다() {
            // given
            면접_시드를_적재한다();

            // when
            List<InterviewQuestion> questions = interviewQuestionRepository.findAll();

            // then
            assertThat(questions)
                    .filteredOn(question -> question.getId() > LAST_VOICED_QUESTION_ID)
                    .isNotEmpty()
                    .allSatisfy(question -> assertThat(question.getAudioKey()).isNull());
        }

        private Resource[] 면접_시드를_적재한다() {
            try {
                Resource[] seeds = new PathMatchingResourcePatternResolver().getResources(INTERVIEW_SEED_LOCATION);
                ResourceDatabasePopulator populator = new ResourceDatabasePopulator(seeds);
                populator.setSqlScriptEncoding(StandardCharsets.UTF_8.name());
                populator.execute(dataSource);
                return seeds;
            } catch (IOException e) {
                throw new UncheckedIOException(e);
            }
        }
    }
}
