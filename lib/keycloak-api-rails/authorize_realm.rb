module Keycloak
  class AuthorizeRealm
    extend Dry::Initializer

    include Dry::Monads[:result]
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    param :session, Types.Instance(Keycloak::Session)

    # @param [String] role_name
    def call(role_name)
      if session.has_realm_role?(role_name)
        Success[:authorized, role_name]
      elsif session.authenticated?
        Failure[:unauthorized, "You do not have #{role_name.to_s.inspect} access"]
      else
        Failure[:unauthenticated, "You are not authenticated"]
      end
    end
  end
end
