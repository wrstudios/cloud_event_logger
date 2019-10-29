class EventLog
  attr_accessor :object, :config, :key, :options, :user

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
      account_object: account_object,
      mls_code: mls_code,
      metadata: metadata
    }
  end

  def event_object
    {
      id: key,
      application: @app_name,
      name: options[:event_name],
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
    if !user.nil?
      if user.try(:client?)
        mls_code = client_mls
      elsif user.try(:agent?)
        mls_code = agent_mls
      else
        mls_code = user_mls
      end
    else
      nil
    end
  end

  def client_mls
    if user.agents.any? && !user.agents.first.mls.nil?
      user.agents.first.mls.key
    end
  end

  def agent_mls
    if !user.mls.nil?
      user.mls.key
    end
  end

  def user_mls
    if !user.mls_credential.nil?
      user.mls_credential.code
    else
      nil
    end
  end

  def user_object
    if user && !user.nil?
      {
        user_id: user.id,
        user_type: user.try(:type),
        user: user.to_json,
        user_eamil: user.email
      }
    end
  end

  def account_object
    if user && !user.nil?
      {
        name: account_name,
        account: account_data
      }
    else
      nil
    end
  end

  def account_data
    if user.account && !user.account.nil?
      user.account.to_json
    else
      nil
    end
  end

  def account_name
    if user.account && !user.account.nil?
      user.account.name
    else
      nil
    end
  end

  def metadata
    options[:metadata] || nil
  end

  def proximity
    options[:metadata][:proximity] || nil
  end

end
