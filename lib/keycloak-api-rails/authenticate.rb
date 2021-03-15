module Keycloak
  class Authenticate
    include Dry::Monads[:do, :result]

    include Import[
      config: "keycloak-api.config",
      key_resolver: "keycloak-api.key_resolver",
      read_token: "keycloak-api.read_token",
      skip_authentication: "keycloak-api.skip_authentication"
    ]

    delegate :token_expiration_tolerance_in_seconds, to: :config

    def call(env)
      return Success[:skipped, "Authentication skipped"] if yield skip_authentication.call(env)

      token = yield read_token.call env

      return Success[:unauthenticated] if token.blank?

      decoded_token = yield decode_and_verify token

      Success[:authenticated, decoded_token]
    end

    private

    def decode_and_verify(token)
      public_key    = key_resolver.find_public_keys

      decoded_token = JSON::JWT.decode token, public_key

      return Failure[:expired, "JWT token is expired", token] if expired?(decoded_token)

      decoded_token.verify! public_key
    rescue JSON::JWT::VerificationFailed => e
      Failure[:verification_failed, "Failed to verify JWT token", token, e]
    rescue JSON::JWK::Set::KidNotFound => e
      Failure[:verification_failed, "Failed to verify JWT token", token, e]
    rescue JSON::JWT::InvalidFormat
      Failure[:invalid_format, "Wrong JWT Format", token]
    else
      Success DecodedToken.new decoded_token
    end

    def expired?(token)
      token_expiration = Time.at(token["exp"]).to_datetime
      token_expiration < Time.now + token_expiration_tolerance_in_seconds.seconds
    end
  end
end
