module Keycloak
  class Middleware
    include Dry::Monads[:result]

    include Import[authenticate: "keycloak-api.authenticate", config: "keycloak-api.config"]

    delegate :logger, to: :config

    def initialize(app, **options)
      super(**options)

      @app = app

      @assigner = Keycloak::Helper::Assigner.new
    end

    def call(env)
      result = authenticate.call(env)

      env["keycloak:auth_result"] = result

      return authentication_failed(env, result) if halt?(result)

      session_opts = { skipped: false, auth_result: result }

      case result
      in Success[:authenticated, decoded_token]
        session_opts[:token] = decoded_token

        @assigner.call env, decoded_token
      in Success[:skipped]
        session_opts[:skipped] = true
      else
        # nothing to do
      end

      env["keycloak:session"] = session = Keycloak::Session.new session_opts
      env["keycloak:authorize_realm"] = session.authorize_realm
      env["keycloak:authorize_resource"] = session.authorize_resource

      @app.call(env)
    end

    private

    def authentication_failed(env, monad)
      headers = build_failure_headers(env, monad)

      body = build_failure_body(env, monad)

      body = body.to_json unless body.kind_of?(String)

      [
        401,
        headers,
        [ body ]
      ]
    end

    def build_failure_headers(env, monad)
      {
        "Content-Type" => "application/json"
      }
    end

    # Currently uses GraphQL error format.
    #
    # @todo Make customizable
    def build_failure_body(env, monad)
      reason, message, token, original_error = monad.failure

      logger.debug message

      {
        errors: [
          {
            message: message,
            extensions: {
              code: "UNAUTHENTICATED"
            }
          }
        ]
      }
    end

    def halt?(result)
      return false unless result.failure?

      config.halt_on_auth_failure?
    end
  end
end
