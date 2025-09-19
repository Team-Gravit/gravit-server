package gravit.code.badge.converter;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import gravit.code.global.exception.domain.CustomErrorCode;
import gravit.code.global.exception.domain.RestApiException;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class JsonNodeConverter implements AttributeConverter<JsonNode, String> {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(JsonNode attribute) {
        try{
            return attribute == null ? "{}" : MAPPER.writeValueAsString(attribute);
        }catch (Exception e){
            throw new RestApiException(CustomErrorCode.JSON_CONVERT_TO_STRING_INVALID);
        }
    }

    @Override
    public JsonNode convertToEntityAttribute(String dbData) {
        try{
            return dbData == null || dbData.isBlank() ? MAPPER.createObjectNode() : MAPPER.readTree(dbData);
        } catch (Exception e) {
            throw new RestApiException(CustomErrorCode.JSON_CONVERT_TO_STRING_INVALID);
        }
    }
}
