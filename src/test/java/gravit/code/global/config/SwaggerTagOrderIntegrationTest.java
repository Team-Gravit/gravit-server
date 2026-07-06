package gravit.code.global.config;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.SoftAssertions.assertSoftly;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

@TCSpringBootTest
@AutoConfigureMockMvc
class SwaggerTagOrderIntegrationTest {

    private static final String TEST_TAG_PREFIX = "Test ";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("[QA 전용] 테스트 태그는 항상 목록 맨 아래 그룹에 모이고, 각 그룹은 알파벳순이며, @Tag 설명은 보존된다")
    void testTagsGroupedLastAndAlphabeticalAndDescriptionsPreserved() throws Exception {
        // given & when — springdoc가 생성한 OpenAPI 문서 조회
        String body = mockMvc.perform(get("/v3/api-docs"))
                .andReturn()
                .getResponse()
                .getContentAsString();

        JsonNode tags = objectMapper.readTree(body).get("tags");

        List<String> tagNames = new ArrayList<>();
        JsonNode sampleTestTag = null;
        for (JsonNode tag : tags) {
            String name = tag.get("name").asText();
            tagNames.add(name);
            if (name.startsWith(TEST_TAG_PREFIX)) {
                sampleTestTag = tag;
            }
        }

        int firstTestIndex = indexOfFirstTestTag(tagNames);
        List<String> businessTags = tagNames.subList(0, firstTestIndex);
        List<String> testTags = tagNames.subList(firstTestIndex, tagNames.size());
        JsonNode finalSampleTestTag = sampleTestTag;

        // then
        assertSoftly(softly -> {
            // 테스트 태그가 실제로 존재한다 (test 프로파일에서 활성)
            softly.assertThat(testTags).isNotEmpty();
            // 첫 테스트 태그 이후는 전부 테스트 태그 — 즉 테스트 그룹이 맨 아래에 연속으로 모임
            softly.assertThat(testTags).allSatisfy(name -> assertThat(name).startsWith(TEST_TAG_PREFIX));
            // 일반 태그 그룹에는 테스트 태그가 섞이지 않음
            softly.assertThat(businessTags).noneMatch(name -> name.startsWith(TEST_TAG_PREFIX));
            // 각 그룹은 이름 알파벳순 (새 도메인이 자동으로 올바른 위치에 들어감을 보장)
            softly.assertThat(businessTags).isSorted();
            softly.assertThat(testTags).isSorted();
            // 재정렬이 태그 객체를 보존하므로 @Tag description이 살아있어야 함
            softly.assertThat(finalSampleTestTag).isNotNull();
            softly.assertThat(finalSampleTestTag.get("description").asText()).isNotBlank();
        });
    }

    private int indexOfFirstTestTag(List<String> tagNames) {
        for (int i = 0; i < tagNames.size(); i++) {
            if (tagNames.get(i).startsWith(TEST_TAG_PREFIX)) {
                return i;
            }
        }
        return tagNames.size();
    }
}
