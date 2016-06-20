require 'figaro'
require 'faraday_middleware'
require 'redis'
require 'logger'
require 'ievkit/version'
require 'ievkit/cache'
require 'ievkit/job'
require 'ievkit/client'
require 'ievkit/railtie' if defined?(Rails)

module Ievkit
  class Log
    class << self
      attr_accessor :logger
    end
    self.logger = Logger.new(STDOUT)
  end

  Figaro.application = Figaro::Application.new(path: 'config/application.yml')
  Figaro.application.load
end
