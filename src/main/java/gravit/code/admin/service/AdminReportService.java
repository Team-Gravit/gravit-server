package gravit.code.admin.service;

import gravit.code.admin.dto.response.ReportDetailResponse;
import gravit.code.admin.dto.response.ReportSummaryResponse;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import gravit.code.report.domain.Report;
import gravit.code.report.domain.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminReportService {

    private final ReportRepository reportRepository;

    @Transactional(readOnly = true)
    public List<ReportSummaryResponse> getAllReportSummary(int page){
        Pageable pageable = PageRequest.of(page,10);
        return reportRepository.findAllReportSummary(pageable);
    }

    @Transactional(readOnly = true)
    public ReportDetailResponse getReportDetail(Long reportId){
        return reportRepository.findReportDetailById(reportId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.REPORT_NOT_FOUND));
    }

    @Transactional
    public void updateResolvedStatus(Long reportId){
        Report report = reportRepository.findById(reportId)
                .orElseThrow(() -> new RestApiException(CustomErrorCode.REPORT_NOT_FOUND));

        report.updateResolvedStatus();

        reportRepository.save(report);

    }
}