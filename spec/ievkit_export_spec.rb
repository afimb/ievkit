require 'spec_helper'

describe Ievkit do
  before(:all) { @referential = ENV['REFERENTIAL_TEST'] }
  before(:all) { @job = Ievkit::Job.new(@referential) }

  context '#export' do
    before(:all) { @export_forwarding_url = @job.post_job(:exporter, :neptune, iev_file: nil, iev_params: ENV['IEV_EXPORT_PARAMS_TEST']) }
    it 'return correct url suffix' do
      expect("#{@job.client.iev_url_prefix}#{@job.client.iev_url_suffix}").to end_with("referentials/#{@referential}/exporter/neptune")
    end
    it 'return forwarding url' do
      expect(@export_forwarding_url).to match('/scheduled_jobs/')
    end

    context 'when check forwarding url' do
      before(:all) { @links = @job.get_job(@export_forwarding_url) }
      it 'return parameters link' do
        expect(@links[:parameters]).to end_with('/parameters.json')
      end
      it 'return action_params link' do
        expect(@links[:action_params]).to end_with('/action_parameters.json')
      end
      it 'return action_report link' do
        expect(@links[:action_report]).to end_with('/action_report.json')
      end
      it 'return cancel link' do
        expect(@links[:cancel]).to match('/scheduled_jobs/')
      end
      it 'forward to terminated_jobs' do
        terminated_job_url = nil
        until terminated_job_url =~ /terminated_jobs/
          terminated_job_url = @job.get_job(@export_forwarding_url)
          sleep(2)
        end
      end
    end

    context 'when check terminated job' do
      before(:all) { @terminated_job_url = @job.get_job(@export_forwarding_url) }
      before(:all) { @links = @job.get_job(@terminated_job_url) }
      it 'return parameters link' do
        expect(@links[:parameters]).to end_with('/parameters.json')
      end
      it 'return action_params link' do
        expect(@links[:action_params]).to end_with('/action_parameters.json')
      end
      it 'return action_report link' do
        expect(@links[:action_report]).to end_with('/action_report.json')
      end
      it 'return delete link' do
        expect(@links[:delete]).to match('/terminated_jobs/')
      end
    end
  end
end
