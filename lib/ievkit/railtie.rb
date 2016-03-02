# frozen_string_literal: true

module Ievkit
  class Railtie < Rails::Railtie
    initializer 'ievkit' do
      Ievkit::Log.logger = Rails.logger
    end
  end
end
