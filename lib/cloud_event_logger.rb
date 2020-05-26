require_relative "version"

class CloudEventLogger
  class Error < StandardError; end

  def self.config
    @config ||= Hashie::Mash.new(default_config)
    if block_given?
      yield @config
    end
    @config
  end

  def self.default_config
    {
      app_name: 'CloudEventLogger',
      log_file: 'event_logger.log',
      cache: {}
    }
  end

  def self.log_event(user, event_name, metadata = {})
    options = {
                metadata: metadata,
                app_name: config[:app_name]
              }
    log = CloudEventLog.new(user, event_name, options)
    self.write_event_log(log)
  end

  private

    def self.write_event_log(log)
      @logger = Logger.new(config[:log_file])
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
      object = log.object
      @logger.info(object.to_json)
    end
end

require_relative 'cloud_event_log'
require 'securerandom'
require 'hashie'
require 'yaml'
require 'json'
require 'pry-rails'
