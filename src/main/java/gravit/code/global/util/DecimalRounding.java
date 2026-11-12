package gravit.code.global.util;

public final class DecimalRounding {

    private static final double FIRST_DECIMAL_SCALE = 10.0;

    private DecimalRounding() {
    }

    public static double roundToFirstDecimal(double value) {
        return Math.round(value * FIRST_DECIMAL_SCALE) / FIRST_DECIMAL_SCALE;
    }
}
