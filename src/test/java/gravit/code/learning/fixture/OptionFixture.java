//package gravit.code.learning.fixture;
//
//import gravit.code.learning.domain.Option;
//import org.springframework.test.util.ReflectionTestUtils;
//
//public class OptionFixture {
//
//    private static Option 선지(
//            String content,
//            String explanation,
//            boolean isAnswer,
//            long problemId
//    ) {
//        Option option = new Option();
//
//        ReflectionTestUtils.setField(option, "content", content);
//        ReflectionTestUtils.setField(option, "explanation", explanation);
//        ReflectionTestUtils.setField(option, "isAnswer", isAnswer);
//        ReflectionTestUtils.setField(option, "problemId", problemId);
//
//        return option;
//    }
//
//    public static Option 정답_선지(long problemId) {
//        return 선지("선지내용", "선지설명", true, problemId);
//    }
//
//    public static Option 오답_선지(long problemId) {
//        return 선지("선지내용", "선지설명", false, problemId);
//    }
//
//    public static Option 저장된_정답_선지(long optionId, long problemId) {
//        Option option = 선지("선지내용", "선지설명", true, problemId);
//
//        ReflectionTestUtils.setField(option, "id", optionId);
//
//        return option;
//    }
//
//    public static Option 저장된_오답_선지(long optionId, long problemId) {
//        Option option = 선지("선지내용", "선지설명", false, problemId);
//
//        ReflectionTestUtils.setField(option, "id", optionId);
//
//        return option;
//    }
//}
