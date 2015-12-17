module Ievkit
  class Client
    attr_reader :iev_url_prefix, :iev_url_suffix, :referential

    def initialize(referential)
      @payload = {}
      @iev_url_prefix = set_iev_url_prefix
      @referential = referential
    end

    def parse_links_headers(links)
      links2 = {}
      links.each do |part|
        section = part.split(';')
        url = section[0][/<(.*)>/,1]
        name = section[1][/rel="(.*)"/,1].to_sym
        links2[name] = url
      end
      links2
    end


    def prepare_post_request(type, options)
      set_files(options)
      @iev_url_suffix = set_iev_url_suffix(type)
      init_connection(iev_url_prefix)
      @connection.post(@iev_url_suffix, @payload)
    end

    def prepare_get_request(url)
      init_connection(url)
      @connection.get
    end

    def init_connection(url)
      @connection = Faraday.new(url: url) do |conn|
        #conn.use Faraday::Response::RaiseError
        conn.request :multipart if @payload.any?
        conn.headers = headers
        conn.response :json, content_type: 'application/json'
        conn.adapter Faraday.default_adapter
      end
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

    private

    def set_iev_url_prefix
      [
          "#{ENV['IEV_HOST']}:#{ENV['IEV_PORT']}",
          ENV['IEV_PATH']
      ].compact * '/'
    end

    def set_iev_url_suffix(type=nil)
      [
          'referentials',
          @referential,
          caller_locations(2,2)[0].label,
          type
      ].compact * '/'
    end

    def set_iev_version
      { :'Accept-Version' => ENV['IEV_VERSION'] }
    end

    def headers
      { }.merge(set_iev_version)
    end
  end
end
