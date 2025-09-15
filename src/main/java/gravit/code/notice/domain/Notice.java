package gravit.code.notice.domain;

import gravit.code.global.doamin.BaseEntity;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.user.domain.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.ZoneId;

import static java.time.temporal.ChronoUnit.MICROS;

@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class Notice extends BaseEntity {

    private static final ZoneId SEOUL = ZoneId.of("Asia/Seoul");
    private static final int TITLE_MAX_SIZE = 200;
    private static final int SUMMARY_MAX_SIZE = 300;


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "summary", nullable = false)
    private String summary;

    @Column(name = "content", nullable = false)
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NoticeStatus status;

    @Column(nullable = false)
    private boolean pinned;

    private LocalDateTime publishedAt;

    @Builder
    public Notice (String title,
                   String summary,
                   String content,
                   User author,
                   NoticeStatus status,
                   boolean pinned,
                   LocalDateTime publishedAt) {
        this.title = title;
        this.summary = summary;
        this.content = content;
        this.author = author;
        this.status = status;
        this.pinned = pinned;
        this.publishedAt = publishedAt;
    }

    public static Notice create(String title,
                                String content,
                                User author,
                                NoticeStatus status,
                                boolean pinned) {
        validate(title, content, status, pinned);
        LocalDateTime publishedAt = getLocalDateTime(status);
        String summary = generateSummary(content);
        validateSummary(summary);

        return Notice.builder()
                .title(title.trim())
                .summary(summary)
                .content(content)
                .author(author)
                .status(status)
                .pinned(pinned)
                .publishedAt(publishedAt)
                .build();
    }

    private static LocalDateTime getLocalDateTime(NoticeStatus status) {
        if(status.equals(NoticeStatus.PUBLISHED)) {
            return LocalDateTime.now(SEOUL).truncatedTo(MICROS);
        }
        return null;
    }

    // 나중에 html 이나 이미지가 들어가면 외부로 빼자.
    private static String generateSummary(String content) {
        String plain = content.replaceAll("\\s+", " ").trim();

        if(plain.length() <= SUMMARY_MAX_SIZE) return plain;

        int end = SUMMARY_MAX_SIZE;
        // 이모지 같은 2유닛 문자를 반으로 잘라버리는걸 방지
        if(Character.isHighSurrogate(plain.charAt(end - 1))) {
            end -= 1;
        }

        return plain.substring(0, end) + "...";
    }

    private static void validate(String title,
                                 String content,
                                 NoticeStatus status,
                                 boolean pinned) {
        validateTitle(title);
        validateContent(content);
        validatePinned(status, pinned);
    }

    private static void validateTitle(String title) {
        if(title == null || title.isBlank()){
            throw new RestApiException(CustomErrorCode.NOTICE_TITLE_INVALID);
        }

        if(title.trim().length() > TITLE_MAX_SIZE){
            throw new RestApiException(CustomErrorCode.NOTICE_TITLE_INVALID);
        }
    }

    private static void validateSummary(String summary) {
        if(summary == null || summary.trim().isEmpty()){
            throw new RestApiException(CustomErrorCode.NOTICE_SUMMARY_INVALID);
        }

        if(summary.trim().length() > SUMMARY_MAX_SIZE){
            throw new RestApiException(CustomErrorCode.NOTICE_SUMMARY_INVALID);
        }
    }

    private static void validateContent(String content) {
        if(content == null || content.trim().isEmpty()){
            throw new RestApiException(CustomErrorCode.NOTICE_CONTENT_INVALID);
        }
    }

    private static void validatePinned(NoticeStatus status, boolean pinned) {
        if(pinned && status != NoticeStatus.PUBLISHED){
            throw new RestApiException(CustomErrorCode.NOTICE_PINNED_MUST_BE_PUBLISHED);
        }
    }
}
