package gravit.code.user.util;

import lombok.experimental.UtilityClass;

@UtilityClass
public class MailHtmlRenderer {

    public static String buildAccountDeletionEmail(String deleteLink) {
        String safeDeleteLink = escapeHtml(deleteLink);

        return TEMPLATE
                .replace("${DELETE_LINK}", deleteLink)
                .replace("${DELETE_LINK_PLAIN}", safeDeleteLink);
    }

    private static final String TEMPLATE = """
            <!doctype html>
            <html lang="ko">
              <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>계정 삭제 확인</title>
              </head>
              <body style="margin:0;padding:0;background:#f5f5f7;">
                <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background:#f5f5f7;padding:20px 0;">
                  <tr>
                    <td align="center">
                      <!-- container -->
                      <table role="presentation" width="560" border="0" cellspacing="0" cellpadding="0"
                             style="width:560px;max-width:560px;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 10px 30px rgba(75,0,130,0.20);">
                        <!-- hero -->
                        <tr>
                          <td style="padding:24px;background:#7c3aed;background-image:linear-gradient(135deg,#9b34ff 0%,#7c3aed 45%,#5b21b6 100%);">
                            <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                              <tr>
                                <td style="font-family:Arial,'Noto Sans KR',sans-serif;color:#ffffff;font-weight:800;font-size:18px;letter-spacing:.3px;">
                                  <span style="display:inline-block;width:28px;height:28px;border-radius:8px;background:#ffffff;color:#7c3aed;text-align:center;line-height:28px;margin-right:8px;font-weight:900;">G</span>
                                  Gravit!
                                </td>
                              </tr>
                              <tr>
                                <td style="padding-top:8px;font-family:Arial,'Noto Sans KR',sans-serif;color:#ffffff;font-weight:800;font-size:24px;line-height:1.25;">
                                  계정 삭제 요청을 확인해주세요
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
            
                        <!-- content -->
                        <tr>
                          <td style="padding:24px 28px 8px 28px;">
                            <p style="margin:0 0 14px 0;font-family:Arial,'Noto Sans KR',sans-serif;font-size:14px;line-height:1.7;color:#374151;">
                              <strong>Gravit!</strong> 의 계정 삭제 요청이 접수되었습니다.
                              아래 버튼을 누르면
                              <span style="display:inline-block;background:#fef2f2;color:#b91c1c;border:1px solid #fee2e2;border-radius:10px;padding:6px 10px;font-size:12px;font-weight:700;">계정이 삭제됩니다.</span>.
                            </p>
            
                            <!-- card -->
                            <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"
                                   style="border:1px solid #eeeeee;border-radius:14px;background:#ffffff;">
                              <tr>
                                <td align="center" style="padding:20px;">
                                  <!-- button -->
                                  <a href="${DELETE_LINK}" target="_blank" rel="noopener noreferrer"
                                     style="display:inline-block;text-decoration:none;background:#7c3aed;background-image:linear-gradient(135deg,#a855f7 0%,#7c3aed 50%,#6d28d9 100%);color:#ffffff;font-family:Arial,'Noto Sans KR',sans-serif;font-weight:800;font-size:15px;letter-spacing:.2px;padding:14px 22px;border-radius:12px;box-shadow:0 8px 18px rgba(124,58,237,0.35),inset 0 0 0 1px rgba(255,255,255,0.18);">
                                    탈퇴 요청 확정하기
                                  </a>
            
                                  <div style="margin-top:10px;font-family:Arial,'Noto Sans KR',sans-serif;font-size:12px;color:#7f1d1d;">
                                    ※ 클릭 시 즉시 확정되며, 관련 데이터는 정책에 따라 순차 삭제됩니다.
                                  </div>
            
                                  <p style="margin:14px 0 6px 0;font-family:Arial,'Noto Sans KR',sans-serif;font-size:12px;color:#6b7280;">
                                    버튼이 동작하지 않으면 아래 링크를 복사해 붙여넣기 하세요.
                                  </p>
                                  <p style="margin:0;font-family:Arial,'Noto Sans KR',sans-serif;font-size:12px;color:#4f46e5;word-break:break-all;">
                                    ${DELETE_LINK_PLAIN}
                                  </p>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
            
                        <!-- footer -->
                        <tr>
                          <td style="padding:16px 28px 22px 28px;border-top:1px solid #f1f1f1;">
                            <p style="margin:0;font-family:Arial,'Noto Sans KR',sans-serif;font-size:12px;color:#6b7280;">
                              본인이 요청하지 않았다면, 이 메일을 무시하거나 고객센터로 문의하세요.
                            </p>
                          </td>
                        </tr>
            
                      </table>
                      <!-- /container -->
                    </td>
                  </tr>
                </table>
              </body>
            </html>
            """;


    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
