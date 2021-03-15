module Keycloak
  class HTTPClient
    include Import[server_url: "keycloak-api.server_url", x509_store: "keycloak-api.x509_store"]

    def get(realm_id, path)
      uri          = build_uri(realm_id, path)
      use_ssl      = uri.scheme == "http" ? false : true

      Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl, cert_store: x509_store) do |http|
        request  = Net::HTTP::Get.new(uri)

        response = http.request(request)

        JSON.parse(response.body)
      end
    end

    private

    def build_uri(realm_id, path)
      string_uri = File.join(server_url, "realms", realm_id, path)

      URI(string_uri)
    end
  end

  class << self
    def http_client
      Container["keycloak-api.http_client"]
    end
  end
end
