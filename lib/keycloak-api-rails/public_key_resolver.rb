module Keycloak
  class PublicKeyResolver
    extend Dry::Initializer

    param :http_client, Types.Instance(Keycloak::HTTPClient)
    param :realm_id, Types::String

    def find_public_keys
      JSON::JWK::Set.new(http_client.get(realm_id, "protocol/openid-connect/certs")["keys"])
    end
  end
end
