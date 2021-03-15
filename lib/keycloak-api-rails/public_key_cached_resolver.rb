module Keycloak
  class PublicKeyCachedResolver
    include Import[config: "keycloak-api.config", http_client: "keycloak-api.http_client"]

    delegate :realm_id, :public_key_cache_ttl, to: :config

    attr_reader :cached_public_key_retrieved_at

    def find_public_keys
      if public_keys_are_outdated?
        @cached_public_keys             = resolver.find_public_keys
        @cached_public_key_retrieved_at = Time.now
      end

      @cached_public_keys
    end

    private

    def resolver
      @resolver ||= PublicKeyResolver.new(http_client, realm_id) 
    end

    def public_keys_are_outdated?
      @cached_public_keys.nil? || @cached_public_key_retrieved_at.nil? || Time.now > (@cached_public_key_retrieved_at + public_key_cache_ttl.seconds)
    end
  end

  class << self
    def public_key_resolver
      Container["keycloak-api.key_resolver"]
    end
  end
end
