package gravit.code.inquiry.repository;

import gravit.code.inquiry.domain.Inquiry;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface InquiryRepository extends JpaRepository<Inquiry, Long> {

    Page<Inquiry> findAllByUserId(
            long userId,
            Pageable pageable
    );

    Optional<Inquiry> findById(long inquiryId);
}
