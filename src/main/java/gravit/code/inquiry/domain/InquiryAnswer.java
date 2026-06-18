package gravit.code.inquiry.domain;

import gravit.code.global.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "inquiry_answer")
public class InquiryAnswer extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "inquiry_id", nullable = false, unique = true)
    private long inquiryId;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "admin_id", nullable = false)
    private long adminId;

    @Builder
    private InquiryAnswer(
            long inquiryId,
            String content,
            long adminId
    ) {
        this.inquiryId = inquiryId;
        this.content = content;
        this.adminId = adminId;
    }

    public static InquiryAnswer create(
            long inquiryId,
            String content,
            long adminId
    ) {
        return InquiryAnswer.builder()
                .inquiryId(inquiryId)
                .content(content)
                .adminId(adminId)
                .build();
    }
}
