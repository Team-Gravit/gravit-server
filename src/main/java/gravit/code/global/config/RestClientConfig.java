package gravit.code.global.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

import java.net.http.HttpClient;
import java.time.Duration;

@Configuration
public class RestClientConfig {

    @Bean
    public RestClient restClient() {
        // 자바 내장 Http 클라이언트 사용
        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(3)) // TCP 연결 맺기까지 3초 
                .build();

        // HttpClient를 Spring 에 맞게 어댑터 패턴으로 연결
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory(httpClient);
        factory.setReadTimeout(Duration.ofSeconds(5)); // TCP 연결 이후 실제 응답 데이터 받기까지 5초

        return RestClient.builder()
                .requestFactory(factory)
                .build();
    }
}
