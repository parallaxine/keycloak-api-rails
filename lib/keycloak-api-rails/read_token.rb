module Keycloak
  class ReadToken
    include Dry::Monads[:result]

    include Import[config: "keycloak-api.config"]

    # @return [Dry::Monads::Result(String, nil)]
    def call(env)
      uri = env["REQUEST_URI"]

      found_token = Helper.read_token uri, env

      return Success(found_token) if found_token.present?

      return Success(nil) if config.allow_unauthenticated_requests?

      Failure[:no_token, "No JWT token provided"]
    end
  end
end
