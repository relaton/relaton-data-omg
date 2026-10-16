# frozen_string_literal: true

require "net/http"
require "uri"

module OmgFetcher
  # Thin GET with a browser-ish UA and a small retry budget. omg.org sits
  # behind a CDN that occasionally 5xxes; three tries over ~4s is plenty.
  module Http
    USER_AGENT = "Mozilla/5.0 (relaton-data-omg crawler)".freeze
    RETRIES = 3

    module_function

    def get(url)
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        req = Net::HTTP::Get.new(uri)
        req["User-Agent"] = USER_AGENT
        RETRIES.times do |i|
          begin
            res = http.request(req)
            return res.body if res.is_a?(Net::HTTPSuccess)

            raise "HTTP #{res.code} for #{url}"
          rescue StandardError
            raise if i == RETRIES - 1

            sleep(2**i)
          end
        end
      end
    end
  end
end
