package gravit.code.global.validator;

import gravit.code.global.annotation.EnumValidation;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class EnumValidator implements ConstraintValidator<EnumValidation, String> {
    private EnumValidation annotation;

    @Override
    public void initialize(EnumValidation constraintAnnotation) {
        this.annotation = constraintAnnotation;
    }

    @Override
    public boolean isValid(
            String value,
            ConstraintValidatorContext context
    ) {
        Object[] enumValues = this.annotation.target().getEnumConstants();
        if (enumValues != null && value != null) {
            for (Object enumValue : enumValues) {
                if (value.equals(enumValue.toString())) {
                    return true;
                }
            }
        }
        return false;
    }
}
