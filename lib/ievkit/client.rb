module Ievkit
  class Client
    attr_reader :iev_url_prefix, :iev_url_prefix_admin, :iev_url_list_tests, :iev_url_suffix, :iev_url_jobs, :referential, :redis

    def initialize(referential)
      @payload = {}
      @referential = referential
      @iev_url_prefix = init_iev_url_prefix
      @iev_url_prefix_admin = init_iev_url_prefix_admin
      @iev_url_list_tests = init_iev_url_list_tests
      @iev_url_jobs = init_iev_url_jobs
      @redis = Redis.new
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

    def prepare_request(url, http_method, disable_cache = false)
      unless disable_cache
        cache_key = [url, http_method.to_s].join('_')
        begin
          response_cached = @redis.cache(cache_key)
          return response_cached if response_cached
        rescue => e
          Ievkit::Log.logger.fatal("Unable to contact Redis server: #{e.message}")
        end
      end
      init_connection(url)
      begin
        response = @connection.send(http_method)
        unless disable_cache
          cache_control = response.headers['cache-control']
          max_age = 0
          no_cache = true
          if cache_control
            max_age = cache_control[/max-age=(.*)/, 1].to_i
            no_cache = false if max_age > 0 && cache_control[/no-transform/]
          end
          return parse_response(response) if no_cache
          @redis.cache(cache_key, max_age) {
            parse_response(response)
          }
        else
          return parse_response(response)
        end
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
      if options[:iev_params].present? && File.file?(options[:iev_params])
        @payload[:file[0]] = Faraday::UploadIO.new(options[:iev_params], 'application/json', 'parameters.json')
      end
      iev_file = options[:iev_file]
      return if iev_file.blank? || !File.file?(iev_file)
      filename = File.basename(iev_file)
      @payload[:file[1]] = Faraday::UploadIO.new(iev_file, 'application/zip', filename)
    end

    def get_stats
      @payload = { key: ENV['iev_admin_key'] }
      init_connection(@iev_url_prefix_admin)
      begin
        response = @connection.get('get_monthly_stats', @payload)
        parse_response(response)
      rescue => e
        Ievkit::Log.logger.fatal("Unable to contact IEV server: #{e.message}")
        return false
      end
    end

    def list_tests(action, format)
      init_connection(@iev_url_list_tests)
      begin
        response = @connection.get("#{action}/#{format}", @payload)
        parse_response(response)
      rescue => e
        Ievkit::Log.logger.fatal("Unable to contact IEV server: #{e.message}")
        return false
      end
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
        raise 'Not Found'
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

    def init_iev_url_prefix_admin
      [
        "#{ENV['IEV_HOST']}:#{ENV['IEV_PORT']}",
        ENV['IEV_PATH'],
        'admin',
        ''
      ].compact * '/'
    end

    def init_iev_url_list_tests
      [
        "#{ENV['IEV_HOST']}:#{ENV['IEV_PORT']}",
        ENV['IEV_PATH'],
        'admin',
        'test_list',
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
      { 'Accept-Version': ENV['IEV_VERSION'] ? ENV['IEV_VERSION'] : "" }
    end
  end
end
