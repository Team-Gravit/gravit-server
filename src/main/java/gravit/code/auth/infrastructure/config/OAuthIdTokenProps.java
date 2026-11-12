package gravit.code.auth.infrastructure.config;

public interface OAuthIdTokenProps {

    String getIssuer(String provider);

    String getClientId(String provider);
}
