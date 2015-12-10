require 'spec_helper'

describe Ievkit do

  subject(:job) { Ievkit::Job.new('t01') }

  it 'has a gem version number' do
    expect(Ievkit::VERSION).not_to be nil
  end

  it 'has figaro and an IEV version number' do
    expect(defined?(Figaro)).not_to be nil
    expect(ENV.key?('IEV_VERSION')).to equal(true)
  end

  context 'when execute import' do
    before { @forwarding_url = job.execute(:importer, :gtfs, { iev_file: ENV['iev_import_file'], iev_params: ENV['iev_import_params'] }) }
    it 'return correct url suffix' do
      expect(job.iev_url_suffix).to end_with('referentials/t01/importer/gtfs')
    end
    it 'return forwarding url' do
      expect(@forwarding_url).to match('/scheduled_jobs/')
    end
  end

  context 'when execute export' do
    before { @forwarding_url = job.execute(:exporter, :neptune, { iev_file: nil, iev_params: ENV['iev_export_params'] }) }
    it 'return correct url suffix' do
      expect(job.iev_url_suffix).to end_with('referentials/t01/exporter/neptune')
    end
    it 'return forwarding url' do
      expect(@forwarding_url).to match('/scheduled_jobs/')
    end
  end

  context 'when execute validate' do
    before { @forwarding_url = job.execute(:validator, :gtfs, { iev_file: ENV['iev_import_file'], iev_params: ENV['iev_validate_params'] }) }
    it 'return correct url suffix' do
      expect(job.iev_url_suffix).to end_with('referentials/t01/validator/gtfs')
    end
    it 'return forwarding url' do
      expect(@forwarding_url).to match('/scheduled_jobs/')
    end
  end
end
