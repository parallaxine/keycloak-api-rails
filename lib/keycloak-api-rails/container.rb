module Keycloak
  class Container
    extend Dry::Container::Mixin

    namespace "keycloak-api" do
      register :config, memoize: true do
        Keycloak::Config.new
      end

      register :authenticate, memoize: true do
        Keycloak::Authenticate.new
      end

      register :http_client, memoize: true do
        Keycloak::HTTPClient.new
      end

      register :key_resolver, memoize: true do
        Keycloak::PublicKeyCachedResolver.new
      end

      register :read_token, memoize: true do
        Keycloak::ReadToken.new
      end

      register :server_url do
        resolve(:config).server_url
      end

      register :skip_authentication, memoize: true do
        Keycloak::SkipAuthentication.new
      end

      register :x509_store, memoize: true do
        resolve(:config).build_x509_store
      end
    end
  end
end
