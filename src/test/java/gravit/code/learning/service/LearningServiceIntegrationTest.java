package gravit.code.learning.service;

import gravit.code.learning.domain.LearningRepository;
import gravit.code.learning.domain.LessonRepository;
import gravit.code.learning.fixture.LearningFixture;
import gravit.code.progress.domain.LessonProgressRepository;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.springframework.beans.factory.annotation.Autowired;

@TCSpringBootTest
class LearningServiceIntegrationTest {

    @Autowired
    private LearningService learningService;

    @Autowired
    private LearningRepository learningRepository;

    @Autowired
    private LessonRepository lessonRepository;

    @Autowired
    private LessonProgressRepository lessonProgressRepository;

    @Autowired
    private LearningFixture learningFixture;

    @BeforeEach
    void setUpTest(){

    }

    @Nested
    @DisplayName("연속학습일을 업데이트할 때")
    class UpdateConsecutiveDays{
    }
}