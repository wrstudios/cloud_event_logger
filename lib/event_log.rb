class EventLog
  attr_accessor :object, :config, :key, :options

  def initialize(config, key, options={})
    @config = config
    @key = key || SecureRandom.uuid
    @options = options
    @start_time = Time.now.utc
    @app_name = config[:app_name] || "CloudEventLogger"
    @user = options[:user] || nil
  end


  def object
    {
      "@timestamp" => @start_time,
      message: "Event logged by #{@app_name}",
      ecs: { version: "1.0.0" },
      event: event_object,
      client: client_object,
      user_object: user_object,
      mls_code: mls_code,
      metadata: metadata
    }
  end

  def event_object
    {
      id: key,
      application: @app_name,
      name: @options[:event_name],
      created: @start_time
    }
  end

  # IP info from Browser if using IPstack
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

  def mls_code
    user = @user
    if !user.nil?
      mls_code = nil
      if user.try(:client)
        if user.agents.any? && !user.agents.first.mls.nil?
          mls_code = user.agents.first.mls.key
        end
      else
        mls_code = user.mls_credential.code
      end
      mls_code
    else
      nil
    end
  end

  def user_object
    user = @user
    if user && !user.nil?
      {
        user_id: user.id,
        user_type: user.try(:type),
        user: user.to_yaml,
        user_eamil: user.email
      }
    end
  end

  def metadata
    @options[:metadata] || nil
  end

  def proximity
    @options[:proximity] || nil
  end

end
