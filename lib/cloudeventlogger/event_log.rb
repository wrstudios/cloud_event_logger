class EventLog
  attr_accessor :data, :object, :config, :key, :score, :original_address, :attempt, :options, :application_keys

  def initialize(config, key, options={})
    @config = config
    @key = key || SecureRandom.uuid
    @options = options

    @start_time = Time.now.utc
    @app_name = config[:app_name] || "CloudGeo"
    @data = {}
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
      }
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

  def data=(value)
    @data = value.kind_of?(Array) ? value.first : value
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
    else
      nil
    end
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

  def geo_point
    if data[:lon] && data[:lat]
      {
        lon: data[:lon] || nil,
        lat: data[:lat] || nil
      }
    else
      nil
    end
  end

  def country_name
    data[:address_components][:country] rescue nil
  end

end
