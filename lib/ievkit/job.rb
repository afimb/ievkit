module Ievkit
  class Job
    attr_reader :client, :response

    def initialize(referential_id)
      @client = Ievkit::Client.new(referential_id)
    end

    def post_job(action, type = nil, options = {})
      send(action, type, options)
    end

    def get_job(url)
      do_job(url, :get)
    end

    def delete_job(url)
      do_job(url, :delete)
    end

    def delete_jobs
      do_job(@client.iev_url_jobs, :delete)
    end

    protected

    def do_job(url, http_method)
      @client.prepare_request(url, http_method)
    end

    def importer(type, options)
      @client.prepare_post_request(type, options)
    end

    def exporter(type, options)
      @client.prepare_post_request(type, options)
    end

    def validator(type, options)
      @client.prepare_post_request(type, options)
    end
  end
end
