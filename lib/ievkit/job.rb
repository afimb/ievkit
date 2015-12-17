module Ievkit
  class Job
    attr_reader :client, :response

    def initialize(referential_id)
      #RestClient.log = @logger = Logger.new(STDERR)
      @client = Ievkit::Client.new(referential_id)
    end

    def execute(action, type=nil, options={})
      @response = send(action, type, options)
      parse_response
    end

    def check_job(url)
      @response = @client.prepare_get_request(url)
      parse_response
    end

    protected

    def importer(type, options)
      @client.prepare_post_request(type, options)
    end

    def exporter(type, options)
      @client.prepare_post_request(type, options)
    end

    def validator(type, options)
      @client.prepare_post_request(type, options)
    end

    def parse_response
      case @response.status
        when 202
          @response.headers['location']
        when 303
          @response.headers['location']
        when 200
          links = @response.headers['link'].split(',')
          @client.parse_links_headers(links)
        else
          @response.body
      end
    end
  end
end
