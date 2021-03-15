module Keycloak
  class SkipAuthentication
    include Dry::Monads[:result]

    include Import[config: "keycloak-api.config"]

    delegate :skip_paths, :logger, :token_expiration_tolerance_in_seconds, to: :config

    # @return [Dry::Monads::Result(Boolean)]
    def call(env)
      method = env["REQUEST_METHOD"]&.downcase&.to_sym
      path   = env["PATH_INFO"]

      return Success(true) if preflight?(method, env)
      return Success(true) if should_skip?(method, path)

      Success(false)
    end

    private

    def should_skip?(method, path)
      method_paths = skip_paths.fetch(method, [])

      method_paths.any? do |path_pattern|
        case path_pattern
        when String then path_pattern == path
        when Regexp then path_pattern.match? path
        end
      end
    end

    def preflight?(method, headers)
      method == :options && headers["HTTP_ACCESS_CONTROL_REQUEST_METHOD"].present?
    end
  end
end
