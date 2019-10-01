class EventLog
  attr_accessor :object, :config, :key, :options

  def initialize(config, key, options={})
    @config = config
    @key = key || SecureRandom.uuid
    @options = options
    @start_time = Time.now.utc
    @app_name = config[:app_name] || "CloudGeo"
  end


  def object
    {
      "@timestamp" => @start_time,
      message: "Event logged by #{config.app_name}",
      ecs: { version: "1.0.0" },
      event: event_object,
      client: client_object,
      organization: {
        id: mls_code
      },
      metadata: metadata
    }
  end

  def event_object
    {
      id: key,
      application: config.app_name,
      name: event_name,
      created: @start_time,
    }
  end

  def client_object
    if proximity
      lon,lat = proximity.split(',')
      {
        geo: {
          location: {
            lon: lon,
            lat: lat
          }
        }
      }
    elsif
      nil
    end
  end

  def metadata
    options[:metadata] || nil
  end

  def event_name
    options[:event_name] || nil
  end

  def mls_code
    options[:mls_code] || nil
  end

  def proximity
    options[:proximity] || nil
  end

  def country_name
    options[:country] || nil
  end

  def city_name
    options[:city] || nil
  end

end
