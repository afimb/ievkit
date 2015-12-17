#require 'logger'
#require 'rest-client'
require 'figaro'
require 'faraday_middleware'
require 'ievkit/version'
require 'ievkit/job'
require 'ievkit/client'

module Ievkit
  Figaro.application = Figaro::Application.new(path: 'config/application.yml')
  Figaro.application.load
end
