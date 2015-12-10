require 'logger'
require 'rest-client'
require 'ievkit/version'
require 'figaro'
require 'faraday_middleware'
require 'ievkit/job'

module Ievkit
  Figaro.application = Figaro::Application.new(path: 'config/application.yml')
  Figaro.application.load
end
