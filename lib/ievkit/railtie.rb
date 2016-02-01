module Ievkit
  class Railtie < Rails::Railtie
    initializer 'ievkit' do |app|
      Ievkit::Log.logger = Rails.logger
    end
  end
end
