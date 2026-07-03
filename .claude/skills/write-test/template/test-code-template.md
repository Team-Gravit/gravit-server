# 테스트 코드 템플릿

## 통합 테스트

```java
package gravit.code.{domain}.service;

import gravit.code.global.exception.domain.RestApiException;
import gravit.code.support.TCSpringBootTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;

import static gravit.code.global.exception.domain.CustomErrorCode.{ERROR_CODE};
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@TCSpringBootTest
@Sql(scripts = "classpath:sql/truncate_all.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class {Target}IntegrationTest {

    @Autowired
    private {TargetClass} target;

    @Autowired
    private {Repository} repository;

    @Nested
    @DisplayName("{기능}할 때")
    class Context {

        @BeforeEach
        void setUp() {
            // 테스트 데이터 준비
        }

        @Test
        void 성공한다() {
            // given
            ...
            // when
            ...
            // then
            assertThat(...).isEqualTo(...);
        }

        @Test
        void 존재하지_않으면_예외를_던진다() {
            // given
            ...
            // when & then
            // 예외 타입과 errorCode를 함께 검증한다 (errorCode 누락 시 회귀 감지 불가)
            assertThatThrownBy(() -> target.method(param))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo({ERROR_CODE});
        }
    }
}
```

## Fixture (정적 팩토리)

```java
package gravit.code.{domain}.fixture;

import gravit.code.{domain}.domain.{Entity};
import org.springframework.test.util.ReflectionTestUtils;

public class {Entity}Fixture {

    public static {Entity} 기본_{엔티티명}(long userId) {
        {Entity} entity = {Entity}.create(...);
        ReflectionTestUtils.setField(entity, "id", 1L);
        return entity;
    }
}
```
