require "ievkit/version"
require "figaro"

module Ievkit
  Figaro.application = Figaro::Application.new(path: "config/application.yml")
  Figaro.application.load
end
