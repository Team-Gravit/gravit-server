package gravit.code.inquiry.repository;

import gravit.code.inquiry.domain.InquiryAnswer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface InquiryAnswerRepository extends JpaRepository<InquiryAnswer, Long> {

    Optional<InquiryAnswer> findByInquiryId(long inquiryId);
}
