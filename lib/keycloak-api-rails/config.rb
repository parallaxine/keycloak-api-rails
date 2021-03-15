module Keycloak
  class Config < Anyway::Config
    attr_config :server_url
    attr_config :realm_id
    attr_config :logger
    attr_config :ca_certificate_file
    attr_config skip_paths: {}
    attr_config token_expiration_tolerance_in_seconds: 10
    attr_config public_key_cache_ttl: 86400
    attr_config custom_attributes: []
    attr_config halt_on_auth_failure: true
    attr_config allow_unauthenticated_requests: false

    def logger
      super || (self.logger = STDOUT && super)
    end

    def logger=(value)
      super coerce_logger value
    end

    # @return [OpenSSL::X509::Store]
    def build_x509_store
      OpenSSL::X509::Store.new.tap do |store|
        store.set_default_paths
        store.add_file(ca_certificate_file) if ca_certificate_file.present?
      end
    end

    private

    def coerce_logger(value)
      return Logger.new("/dev/null") if value.blank?

      case value
      when Logger then value
      when /\ARails\z/i then Rails.logger
      when /\ASTDOUT\z/i then Logger.new(STDOUT)
      when /\ASTDERR\z/i then Logger.new(STDERR)
      when String then Logger.new(value)
      when IO then Logger.new(value)
      else
        Logger.new("/dev/null")
      end
    end
  end

  module WithConfig
    def config
      Keycloak::Container["keycloak-api.config"]
    end

    def logger
      config.logger
    end
  end

  class << self
    include WithConfig

    def configure
      yield self.config
    end
  end
end
