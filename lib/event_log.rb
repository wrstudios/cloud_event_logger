class EventLog
  attr_accessor :object, :config, :key, :options, :user

  def initialize(config, key, options={})
    @config = config
    @key = key || SecureRandom.uuid
    @options = options
    @start_time = Time.now.utc
    @app_name = config[:app_name] || "CloudEventLogger"
    @user = options[:user] || nil
    @mls = options[:mls] || nil
  end


  def object
    {
      "@timestamp" => @start_time,
      message: "Event logged by #{@app_name}",
      ecs: { version: "1.0.0" },
      event: event_object,
      client: client_object,
      user: user_object,
      mls: mls_object,
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

  def user_object
    if user && !user.nil?
      {
        user_id: user.id,
        user_type: user.try(:type),
        user_email: user.email,
        account_name: account_name
      }
    else
      nil
    end
  end

  def mls_object
    if user && !user.nil?
      mls_data
    else
      nil
    end
  end

  def mls_data
    if !user.nil?
      if user.try(:client?)
        client_mls
      elsif user.try(:agent?)
        agent_mls
      else
        user_mls
      end
    else
      nil
    end
  end

  def client_mls
    if user.agents.any? && !user.agents.first.mls.nil?
      {
        mls_code: user.agents.first.mls_credential.code,
        mls_name: user.agents.first.mls_credential.name
      }
    else
      nil
    end
  end

  def agent_mls
    if !user.mls.nil?
      {
        mls_code: user.mls_credential.code,
        mls_name: user.mls_credential.name
      }
    else
      nil
    end
  end

  def user_mls
    if !user.mls_credential.nil?
      {
        mls_code: user.mls_credential.code,
        mls_name: user.mls_credential.name
      }
    else
      nil
    end
  end

  def account_name
    if user.try(:client?)
      agent = user.agents.first
    else
      agent = user
    end

    if agent.try(:account) && !agent.account.nil?
      agent.account.try(:name).try(:upcase)
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
