module Keycloak
  class DecodedToken < Dry::Struct
    delegate :token_expiration_tolerance_in_seconds, to: :config

    KEY_MAP = {
      "exp" => :expires_at,
      "iat" => :issued_at,
      "auth_time" => :authorized_at,
      "azp" => :authorized_party,
      "typ" => :type,
      "aud" => :audience,
      "allowed-origins" => :allowed_origins,
    }.with_indifferent_access.freeze

    transform_keys do |k|
      KEY_MAP[k] || k.to_sym
    end

    class RoleMap < Dry::Struct
      transform_keys(&:to_sym)
      transform_types do |type|
        if type.default?
          type.constructor do |value|
            value.nil? ? Dry::Types::Undefined : value
          end
        else
          type
        end
      end

      attribute :roles, Types::Array.of(Types::String).default { [] }

      def has_role?(name)
        name.to_s.in? roles
      end
    end

    attribute :expires_at, Types::Timestamp
    attribute :issued_at, Types::Timestamp
    attribute :authorized_at, Types::Timestamp
    attribute :jti, Types::String
    attribute :audience, Types::String
    attribute :sub, Types::String
    attribute :type, Types::String
    attribute :authorized_party, Types::String
    attribute :nonce, Types::String
    attribute :session_state, Types::String
    attribute? :locale, Types::String.optional
    attribute :allowed_origins, Types::Array.of(Types::String)
    attribute :realm_access, RoleMap.default { {} }
    attribute :resource_access, Types::Hash.map(Types::String, RoleMap).default { { "account" => {} } }
    attribute :scope, Types::String
    attribute? :email_verified, Types::Bool
    attribute? :name, Types::String.optional
    attribute? :preferred_username, Types::String.optional
    attribute? :given_name, Types::String.optional
    attribute? :family_name, Types::String.optional
    attribute? :email, Types::String.optional

    alias keycloak_id sub

    def config
      Keycloak.config
    end

    def expired?(now: Time.now)
      expires_at < ( now + token_expiration_tolerance_in_seconds )
    end

    def has_realm_role?(name)
      name.to_s.in? realm_access.roles
    end

    def has_resource_role?(resource_name, role_name)
      resource_access[resource_name.to_s]&.has_role?(role_name)
    end

    def slice(*keys)
      keys.flatten!

      keys.each_with_object({}.with_indifferent_access) do |k, h|
        h[k] = public_send(k)
      end
    end
  end
end
