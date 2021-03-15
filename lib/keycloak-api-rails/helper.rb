module Keycloak
  class Helper
    CURRENT_USER_ID_KEY          = "keycloak:keycloak_id"
    CURRENT_AUTHORIZED_PARTY_KEY = "keycloak:authorized_party"
    CURRENT_USER_EMAIL_KEY       = "keycloak:email"
    CURRENT_USER_LOCALE_KEY      = "keycloak:locale"
    CURRENT_USER_ATTRIBUTES      = "keycloak:attributes"
    ROLES_KEY                    = "keycloak:roles"
    RESOURCE_ROLES_KEY           = "keycloak:resource_roles"
    TOKEN_KEY                    = "keycloak:token"
    QUERY_STRING_TOKEN_KEY       = "authorizationToken"

    class << self
      def current_user_id(env)
        env[CURRENT_USER_ID_KEY]
      end

      def keycloak_token(env)
        env[TOKEN_KEY]
      end

      def current_authorized_party(env)
        env[CURRENT_AUTHORIZED_PARTY_KEY]
      end

      def current_user_email(env)
        env[CURRENT_USER_EMAIL_KEY]
      end

      def current_user_locale(env)
        env[CURRENT_USER_LOCALE_KEY]
      end

      def current_user_roles(env)
        env[ROLES_KEY]
      end

      def current_resource_roles(env)
        env[RESOURCE_ROLES_KEY]
      end

      def current_user_custom_attributes(env)
        env[CURRENT_USER_ATTRIBUTES]
      end

      def current_user_roles(env)
        env[ROLES_KEY]
      end

      def read_token(uri, headers)
        read_token_from_query_string(uri).presence || read_token_from_headers(headers)
      end

      def read_token_from_query_string(uri)
        parsed_uri         = URI.parse(uri)
        query              = URI.decode_www_form(parsed_uri.query || "")
        query_string_token = query.detect { |param| param.first == QUERY_STRING_TOKEN_KEY }
        query_string_token&.second
      end

      def create_url_with_token(uri, token)
        uri       = URI(uri)
        params    = URI.decode_www_form(uri.query || "").reject { |query_string| query_string.first == QUERY_STRING_TOKEN_KEY }
        params    << [QUERY_STRING_TOKEN_KEY, token]
        uri.query = URI.encode_www_form(params)
        uri.to_s
      end

      def read_token_from_headers(headers)
        headers["HTTP_AUTHORIZATION"]&.gsub(/^Bearer /, "") || ""
      end
    end

    # @api private
    class Assigner
      include Keycloak::Import[config: "keycloak-api.config"]

      # @param [Hash] env
      # @param [Hash] decoded_token
      def call(env, decoded_token)
        assign_current_user_id env, decoded_token
        assign_current_authorized_party env, decoded_token
        assign_current_user_email env, decoded_token
        assign_current_user_locale env, decoded_token
        assign_current_user_custom_attributes env, decoded_token
        assign_realm_roles env, decoded_token
        assign_resource_roles env, decoded_token
        assign_keycloak_token env, decoded_token
      end

      private

      def assign_current_user_id(env, token)
        env[CURRENT_USER_ID_KEY] = token.sub
      end

      def assign_keycloak_token(env, token)
        env[TOKEN_KEY] = token
      end

      def assign_current_authorized_party(env, token)
        env[CURRENT_AUTHORIZED_PARTY_KEY] = token.authorized_party
      end

      def assign_current_user_email(env, token)
        env[CURRENT_USER_EMAIL_KEY] = token.email
      end

      def assign_current_user_locale(env, token)
        env[CURRENT_USER_LOCALE_KEY] = token.locale
      end

      def assign_realm_roles(env, token)
        env[ROLES_KEY] = token.realm_access.roles
      end

      def assign_resource_roles(env, token)
        env[RESOURCE_ROLES_KEY] = token.resource_access.each_with_object({}) do |(name, resource_attributes), resource_roles|
          resource_roles[name] = resource_attributes.roles
        end
      end

      def assign_current_user_custom_attributes(env, token)
        attribute_names = config.custom_attributes

        env[CURRENT_USER_ATTRIBUTES] = token.slice(*attribute_names)
      end
    end
  end
end
