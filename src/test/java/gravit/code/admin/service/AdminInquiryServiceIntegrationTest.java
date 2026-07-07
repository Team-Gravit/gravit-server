package gravit.code.admin.service;

import gravit.code.admin.dto.request.InquiryAnswerCreateRequest;
import gravit.code.admin.dto.request.InquiryAnswerUpdateRequest;
import gravit.code.admin.dto.response.InquiryDetailResponse;
import gravit.code.admin.dto.response.InquiryListItemResponse;
import gravit.code.global.dto.response.PageResponse;
import gravit.code.global.event.InquiryAnsweredEvent;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.inquiry.domain.Inquiry;
import gravit.code.inquiry.domain.InquiryAnswer;
import gravit.code.inquiry.domain.InquiryStatus;
import gravit.code.inquiry.domain.InquiryType;
import gravit.code.inquiry.repository.InquiryAnswerRepository;
import gravit.code.inquiry.repository.InquiryRepository;
import gravit.code.support.TCSpringBootTest;
import gravit.code.user.domain.User;
import gravit.code.user.fixture.UserFixture;
import gravit.code.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.event.ApplicationEvents;
import org.springframework.test.context.event.RecordApplicationEvents;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_ALREADY_ANSWERED;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_ANSWER_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.INQUIRY_NOT_FOUND;
import static gravit.code.global.exception.domain.CustomErrorCode.PAGE_MUST_START_FROM_1;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

@TCSpringBootTest
@RecordApplicationEvents
class AdminInquiryServiceIntegrationTest {

    @Autowired
    private AdminInquiryService adminInquiryService;

    @Autowired
    private InquiryRepository inquiryRepository;

    @Autowired
    private InquiryAnswerRepository inquiryAnswerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserFixture userFixture;

    @Autowired
    private ApplicationEvents events;

    private long submitterId;
    private String submitterNickname;
    private String submitterEmail;
    private long adminId;

    @BeforeEach
    void setUp() {
        User submitter = userFixture.일반_유저(1);
        submitterId = submitter.getId();
        submitterNickname = submitter.getNickname();
        submitterEmail = submitter.getEmail();

        adminId = userFixture.일반_유저(2).getId();
    }

    @Nested
    @DisplayName("문의 목록을 조회할 때")
    class GetInquiries {

        @Test
        void 상태_미지정이면_전체_문의를_id_내림차순으로_조회하고_작성자_닉네임을_매핑한다() {
            // given
            savePending(submitterId, "첫 번째");
            savePending(submitterId, "두 번째");
            Inquiry latest = savePending(submitterId, "세 번째");

            // when
            PageResponse<InquiryListItemResponse> result = adminInquiryService.getInquiries(null, 1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(result.contents()).hasSize(3);
                softly.assertThat(result.contents().get(0).inquiryId()).isEqualTo(latest.getId());
                softly.assertThat(result.contents().get(0).title()).isEqualTo("세 번째");
                softly.assertThat(result.contents().get(0).submitterId()).isEqualTo(submitterId);
                softly.assertThat(result.contents().get(0).submitterNickname()).isEqualTo(submitterNickname);
            });
        }

        @Test
        void status로_필터링하면_해당_상태의_문의만_조회된다() {
            // given
            savePending(submitterId, "대기 문의");
            saveResolved(submitterId, "완료 문의");

            // when
            PageResponse<InquiryListItemResponse> pending = adminInquiryService.getInquiries(InquiryStatus.PENDING, 1);
            PageResponse<InquiryListItemResponse> resolved = adminInquiryService.getInquiries(InquiryStatus.RESOLVED, 1);

            // then
            assertSoftly(softly -> {
                softly.assertThat(pending.contents())
                        .extracting(InquiryListItemResponse::status)
                        .containsExactly(InquiryStatus.PENDING.name());
                softly.assertThat(resolved.contents())
                        .extracting(InquiryListItemResponse::status)
                        .containsExactly(InquiryStatus.RESOLVED.name());
            });
        }

        @Test
        void 문의가_없으면_빈_목록을_반환한다() {
            // when
            PageResponse<InquiryListItemResponse> result = adminInquiryService.getInquiries(null, 1);

            // then
            assertThat(result.contents()).isEmpty();
        }

        @Test
        void 탈퇴한_작성자의_문의는_작성자_닉네임이_null로_조회된다() {
            // given
            User leaving = userFixture.일반_유저(9);
            long leavingId = leaving.getId();
            savePending(leavingId, "탈퇴 예정자의 문의");
            userRepository.delete(leaving); // @SQLDelete: soft delete

            // when
            PageResponse<InquiryListItemResponse> result = adminInquiryService.getInquiries(null, 1);

            // then
            InquiryListItemResponse item = result.contents().stream()
                    .filter(i -> i.submitterId() == leavingId)
                    .findFirst()
                    .orElseThrow();
            assertThat(item.submitterNickname()).isNull();
        }

        @Test
        void page가_1보다_작으면_예외가_발생한다() {
            // when & then
            assertThatThrownBy(() -> adminInquiryService.getInquiries(null, 0))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(PAGE_MUST_START_FROM_1);
        }
    }

    @Nested
    @DisplayName("문의 상세를 조회할 때")
    class GetInquiry {

        @Test
        void 작성자_정보와_답변을_함께_조회한다() {
            // given
            Inquiry inquiry = saveResolved(submitterId, "완료된 문의");
            saveAnswer(inquiry.getId(), "확인 후 반영했습니다.");

            // when
            InquiryDetailResponse detail = adminInquiryService.getInquiry(inquiry.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(detail.inquiryId()).isEqualTo(inquiry.getId());
                softly.assertThat(detail.status()).isEqualTo(InquiryStatus.RESOLVED.name());
                softly.assertThat(detail.submitterId()).isEqualTo(submitterId);
                softly.assertThat(detail.submitterNickname()).isEqualTo(submitterNickname);
                softly.assertThat(detail.submitterEmail()).isEqualTo(submitterEmail);
                softly.assertThat(detail.answer()).isNotNull();
                softly.assertThat(detail.answer().content()).isEqualTo("확인 후 반영했습니다.");
                softly.assertThat(detail.answer().adminId()).isEqualTo(adminId);
            });
        }

        @Test
        void 답변이_없으면_answer가_null로_조회된다() {
            // given
            Inquiry inquiry = savePending(submitterId, "답변 대기 문의");

            // when
            InquiryDetailResponse detail = adminInquiryService.getInquiry(inquiry.getId());

            // then
            assertSoftly(softly -> {
                softly.assertThat(detail.status()).isEqualTo(InquiryStatus.PENDING.name());
                softly.assertThat(detail.answer()).isNull();
            });
        }

        @Test
        void 존재하지_않는_문의면_예외가_발생한다() {
            // when & then
            assertThatThrownBy(() -> adminInquiryService.getInquiry(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("문의에 답변을 등록할 때")
    class Answer {

        @Test
        void 답변이_저장되고_상태가_RESOLVED로_전환된다() {
            // given
            Inquiry inquiry = savePending(submitterId, "버그 문의");
            InquiryAnswerCreateRequest request = new InquiryAnswerCreateRequest("재현 확인 후 수정했습니다.");

            // when
            InquiryDetailResponse detail = adminInquiryService.answer(adminId, inquiry.getId(), request);

            // then
            Inquiry persisted = inquiryRepository.findById(inquiry.getId()).orElseThrow();
            InquiryAnswer savedAnswer = inquiryAnswerRepository.findByInquiryId(inquiry.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(detail.status()).isEqualTo(InquiryStatus.RESOLVED.name());
                softly.assertThat(detail.answer()).isNotNull();
                softly.assertThat(detail.answer().content()).isEqualTo("재현 확인 후 수정했습니다.");
                softly.assertThat(detail.answer().adminId()).isEqualTo(adminId);
                softly.assertThat(persisted.getStatus()).isEqualTo(InquiryStatus.RESOLVED);
                softly.assertThat(savedAnswer.getContent()).isEqualTo("재현 확인 후 수정했습니다.");
            });
        }

        @Test
        void 작성자에게_보낼_InquiryAnsweredEvent를_발행한다() {
            // given
            Inquiry inquiry = savePending(submitterId, "답변 알림 대상 문의");
            InquiryAnswerCreateRequest request = new InquiryAnswerCreateRequest("답변 드립니다.");

            // when
            adminInquiryService.answer(adminId, inquiry.getId(), request);

            // then
            List<InquiryAnsweredEvent> published = events.stream(InquiryAnsweredEvent.class).toList();
            assertThat(published).hasSize(1);
            assertSoftly(softly -> {
                softly.assertThat(published.get(0).inquiryId()).isEqualTo(inquiry.getId());
                softly.assertThat(published.get(0).userId()).isEqualTo(submitterId);
                softly.assertThat(published.get(0).title()).isEqualTo(inquiry.getTitle());
            });
        }

        @Test
        void 이미_답변이_등록된_문의면_예외가_발생한다() {
            // given
            Inquiry inquiry = savePending(submitterId, "중복 답변 문의");
            saveAnswer(inquiry.getId(), "먼저 등록된 답변");
            InquiryAnswerCreateRequest request = new InquiryAnswerCreateRequest("나중에 등록 시도하는 답변");

            // when & then
            assertThatThrownBy(() -> adminInquiryService.answer(adminId, inquiry.getId(), request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ALREADY_ANSWERED);
        }

        @Test
        void 존재하지_않는_문의면_예외가_발생한다() {
            // given
            InquiryAnswerCreateRequest request = new InquiryAnswerCreateRequest("답변");

            // when & then
            assertThatThrownBy(() -> adminInquiryService.answer(adminId, 999L, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("답변을 수정할 때")
    class UpdateAnswer {

        @Test
        void 답변_내용이_수정되고_상태는_RESOLVED로_유지된다() {
            // given
            Inquiry inquiry = saveResolved(submitterId, "답변 수정 대상");
            saveAnswer(inquiry.getId(), "초기 답변");
            InquiryAnswerUpdateRequest request = new InquiryAnswerUpdateRequest("수정된 답변");

            // when
            InquiryDetailResponse detail = adminInquiryService.updateAnswer(inquiry.getId(), request);

            // then
            InquiryAnswer persisted = inquiryAnswerRepository.findByInquiryId(inquiry.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(detail.answer().content()).isEqualTo("수정된 답변");
                softly.assertThat(detail.status()).isEqualTo(InquiryStatus.RESOLVED.name());
                softly.assertThat(persisted.getContent()).isEqualTo("수정된 답변");
            });
        }

        @Test
        void 등록된_답변이_없으면_예외가_발생한다() {
            // given
            Inquiry inquiry = savePending(submitterId, "답변 없는 문의");
            InquiryAnswerUpdateRequest request = new InquiryAnswerUpdateRequest("수정 답변");

            // when & then
            assertThatThrownBy(() -> adminInquiryService.updateAnswer(inquiry.getId(), request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ANSWER_NOT_FOUND);
        }

        @Test
        void 존재하지_않는_문의면_예외가_발생한다() {
            // given
            InquiryAnswerUpdateRequest request = new InquiryAnswerUpdateRequest("수정 답변");

            // when & then
            assertThatThrownBy(() -> adminInquiryService.updateAnswer(999L, request))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }
    }

    @Nested
    @DisplayName("답변을 삭제할 때")
    class DeleteAnswer {

        @Test
        void 답변이_삭제되고_상태가_PENDING으로_되돌아간다() {
            // given
            Inquiry inquiry = saveResolved(submitterId, "답변 삭제 대상");
            saveAnswer(inquiry.getId(), "삭제될 답변");

            // when
            adminInquiryService.deleteAnswer(inquiry.getId());

            // then
            Inquiry persisted = inquiryRepository.findById(inquiry.getId()).orElseThrow();
            assertSoftly(softly -> {
                softly.assertThat(inquiryAnswerRepository.findByInquiryId(inquiry.getId())).isEmpty();
                softly.assertThat(persisted.getStatus()).isEqualTo(InquiryStatus.PENDING);
            });
        }

        @Test
        void 등록된_답변이_없으면_예외가_발생한다() {
            // given
            Inquiry inquiry = savePending(submitterId, "답변 없는 문의");

            // when & then
            assertThatThrownBy(() -> adminInquiryService.deleteAnswer(inquiry.getId()))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_ANSWER_NOT_FOUND);
        }

        @Test
        void 존재하지_않는_문의면_예외가_발생한다() {
            // when & then
            assertThatThrownBy(() -> adminInquiryService.deleteAnswer(999L))
                    .isInstanceOf(RestApiException.class)
                    .extracting(e -> ((RestApiException) e).getErrorCode())
                    .isEqualTo(INQUIRY_NOT_FOUND);
        }
    }

    private Inquiry savePending(
            long userId,
            String title
    ) {
        return inquiryRepository.save(
                Inquiry.create(title, InquiryType.BUG_REPORT, "내용", userId)
        );
    }

    private Inquiry saveResolved(
            long userId,
            String title
    ) {
        Inquiry inquiry = Inquiry.create(title, InquiryType.BUG_REPORT, "내용", userId);
        ReflectionTestUtils.setField(inquiry, "status", InquiryStatus.RESOLVED);
        return inquiryRepository.save(inquiry);
    }

    private InquiryAnswer saveAnswer(
            long inquiryId,
            String content
    ) {
        return inquiryAnswerRepository.save(
                InquiryAnswer.create(inquiryId, content, adminId)
        );
    }
}
