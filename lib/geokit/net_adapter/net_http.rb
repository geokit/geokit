module Geokit
  module NetAdapter
    class NetHttp
      def self.do_get(url)
        uri = URI.parse(url)
        req = Net::HTTP::Get.new(url)
        req.basic_auth(uri.user, uri.password) if uri.userinfo
        net_http_args = [uri.host, uri.port]
        if (proxy_uri_string = Geokit::Geocoders.proxy)
          proxy_uri = URI.parse(proxy_uri_string)
          net_http_args += [proxy_uri.host,
                            proxy_uri.port,
                            proxy_uri.user,
                            proxy_uri.password]
        end
        http = Net::HTTP.new(*net_http_args)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = Geokit::Geocoders.ssl_verify_mode
        end
        http.start { |h| h.request(req) }
      end

      def self.success?(response)
        response.is_a?(Net::HTTPSuccess)
      end
    end
  end
end
