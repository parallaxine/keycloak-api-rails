module Keycloak
  class AuthorizeResource
    extend Dry::Initializer

    include Dry::Monads[:result]
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    param :session, Types.Instance(Keycloak::Session)

    # @param [String] role_name
    def call(resource_name, role_name)
      if session.has_resource_role?(resource_name, role_name)
        Success[:authorized, resource_name, role_name]
      elsif session.authenticated?
        Failure[:unauthorized, "You do not have #{role_name.to_s.inspect} access on #{resource_name.to_s.inspect}"]
      else
        Failure[:unauthenticated, "You are not authenticated"]
      end
    end
  end
end
