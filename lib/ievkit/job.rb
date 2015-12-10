module Ievkit
  class Job
    attr_accessor :iev_version, :referential_id
    attr_reader  :iev_url_prefix, :iev_url_suffix

    def initialize(referential_id)
      RestClient.log = @logger = Logger.new(STDERR)
      self.iev_version = ENV['IEV_VERSION']
      self.referential_id = referential_id
      @payload = {}
      set_iev_url_prefix
    end

    def execute(action, type=nil, options={})
      response = self.send(action, type, options)
      parse_response(response)
    end

    protected

    def importer(type, options)
      prepare_request(type, options)
    end

    def exporter(type, options)
      prepare_request(type, options)
    end

    def validator(type, options)
      prepare_request(type, options)
    end

    def parse_response(response)
      case response.status
        when 202
          response.headers['location']
        else
          response.body
      end
    end

    protected

    def prepare_request(type, options)
      set_iev_url_suffix(type)
      set_files(options)

      connection = Faraday.new(url: @iev_url_prefix) do |conn|
        #conn.use Faraday::Response::RaiseError
        conn.request :multipart
        conn.headers = headers
        conn.response :json, content_type: 'application/json'
        conn.adapter Faraday.default_adapter
      end

      connection.post(@iev_url_suffix, @payload)
    end

    def set_files(options)
      if options
        iev_file = options[:iev_file]
        @payload[:file[0]] = Faraday::UploadIO.new(options[:iev_params], 'application/json', 'parameters.json')
        if iev_file
          filename = File.basename(iev_file)
          @payload[:file[1]] = Faraday::UploadIO.new(iev_file, 'application/zip', filename)
        end
      end
    end

    def set_iev_url_prefix
      @iev_url_prefix = [
          "#{ENV['IEV_HOST']}:#{ENV['IEV_PORT']}",
          ENV['IEV_PATH']
      ].compact * '/'
    end

    def set_iev_url_suffix(type=nil)
      @iev_url_suffix = [
          'referentials',
          self.referential_id,
          caller_locations(2,2)[0].label,
          type
      ].compact * '/'
    end

    def set_iev_version
      { :'Accept-Version' => self.iev_version }
    end

    def headers
      { }.merge(set_iev_version)
    end
  end
end
