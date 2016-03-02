module Ievkit
  class Client
    attr_reader :iev_url_prefix, :iev_url_suffix, :iev_url_jobs, :referential

    def initialize(referential)
      @payload = {}
      @referential = referential
      @iev_url_prefix = init_iev_url_prefix
      @iev_url_jobs = init_iev_url_jobs
    end

    def prepare_post_request(type, options)
      init_files(options)
      @iev_url_suffix = init_iev_url_suffix(type)
      init_connection(iev_url_prefix)
      begin
        response = @connection.post(@iev_url_suffix, @payload)
        parse_response(response)
      rescue => e
        Ievkit::Log.logger.fatal("Unable to contact IEV server: #{e.message}")
        return false
      end
    end

    def prepare_request(url, http_method)
      init_connection(url)
      begin
        response = @connection.send(http_method)
        parse_response(response)
      rescue => e
        Ievkit::Log.logger.fatal("Unable to contact IEV server: #{e.message}")
        return false
      end
    end

    def init_connection(url)
      @connection = Faraday.new(url: url) do |conn|
        conn.request :multipart if @payload.any?
        conn.headers = headers
        conn.response :json, content_type: 'application/json'
        conn.adapter Faraday.default_adapter
      end
    end

    def init_files(options)
      return unless options
      iev_file = options[:iev_file]
      @payload[:file[0]] = Faraday::UploadIO.new(options[:iev_params], 'application/json', 'parameters.json')
      return unless iev_file
      filename = File.basename(iev_file)
      @payload[:file[1]] = Faraday::UploadIO.new(iev_file, 'application/zip', filename)
    end

    protected

    def headers
      {}.merge(init_iev_version)
    end

    def parse_links_headers(response)
      return response.body if response.headers['link'].to_s.empty?
      {}.tap do |hash|
        response.headers['link'].split(',').each do |part|
          section = part.split(';')
          name = section[1][/rel="(.*)"/, 1].to_sym
          hash[name] = section[0][/<(.*)>/, 1]
        end
      end
    end

    def parse_response(response)
      case response.status
      when 202
        response.headers['location']
      when 303
        response.headers['location']
      when 200
        parse_links_headers(response)
      when 404
        raise 'IEV not accessible'
      else
        response.body
      end
    rescue => e
      Ievkit::Log.logger.fatal("Unable to parse response: #{e.message}")
      return false
    end

    private

    def init_iev_url_prefix
      [
        "#{ENV['IEV_HOST']}:#{ENV['IEV_PORT']}",
        ENV['IEV_PATH'],
        'referentials',
        @referential,
        ''
      ].compact * '/'
    end

    def init_iev_url_suffix(type = nil)
      [
        caller_locations(2, 2)[0].label,
        type
      ].compact * '/'
    end

    def init_iev_url_jobs
      [@iev_url_prefix, 'jobs'].join
    end

    def init_iev_version
      { 'Accept-Version': ENV['IEV_VERSION'] }
    end
  end
end
