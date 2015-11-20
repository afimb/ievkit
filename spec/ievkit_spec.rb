require 'spec_helper'

describe Ievkit do
  it 'has a gem version number' do
    expect(Ievkit::VERSION).not_to be nil
  end

  it 'has figaro and an IEV version number' do
    expect(defined?(Figaro)).not_to be nil
    expect(ENV.key?('IEV_VERSION')).to equal(true)
  end
end
