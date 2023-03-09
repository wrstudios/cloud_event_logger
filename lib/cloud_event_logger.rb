require_relative "version"

class CloudEventLogger
  class Error < StandardError; end

  class << self
    def default_config
      {
        app_name: 'CloudEventLogger',
        log_file: 'event_logger.log',
        opensearch_host: nil,
        cache: {}
      }
    end

    def config
      @config ||= Hashie::Mash.new(default_config)
      if block_given?
        @logger = nil
        yield @config    
      end
      @config
    end

    def log_event(user, event_name, metadata = {})
      options = { metadata: metadata, app_name: config.app_name }
      log = CloudEventLog.new(user, event_name, options)
      write(log)
    end

    def log_external_event(event_name, metadata = {})
      options = { metadata: metadata, app_name: config.app_name }
      log = CloudEventLog.new(nil, event_name, options)
      write(log)
    end

    private

    def write(log)
      if config.opensearch_host
        index_event_log(log.as_json)
      else
        Thread.new {
          logger.info(log.as_json)
        }
      end
    end

    def logger
      @logger ||= Logger.new(config.log_file).tap do |logger|
        logger.formatter = proc {|_, _, _, msg| "#{msg}\n" }
      end
    end

    def index_pattern
      ["events", Time.now.strftime("%Y%m%d")].join("-")
    end

    def index_event_log(event)
      url = URI("#{config.opensearch_host}/#{index_pattern}/_doc")
      http = Net::HTTP.new(url.host, url.port)

      if url.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = 'application/json'
      request.body = event
      http.request(request)
    end

  end


end

require_relative 'cloud_event_log'
require 'date'
require 'securerandom'
require 'hashie'
require 'yaml'
require 'json'
require 'uri'
require 'net/http'
require 'openssl'

