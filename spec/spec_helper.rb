# frozen_string_literal: true

require "bundler/setup"
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "omg_fetcher"

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
end
