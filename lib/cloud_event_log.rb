class CloudEventLog
  attr_accessor :object, :options, :user, :event_name

  def initialize(user, event_name, options={})
    @user = user || nil
    @event_name = event_name
    @options = options
    @app_name = options[:app_name] || "CloudEventLogger"
    @start_time = Time.now.utc
  end

  def object
    {
      "@timestamp" => @start_time,
      message: "Event logged by #{@app_name}",
      ecs: { version: "1.0.0" },
      event: event_object,
      user: user_object,
      metadata: metadata
    }
  end

  def event_object
    {
      application: @app_name,
      name: @event_name,
      created: @start_time,
      day_of_week: @start_time.strftime("%A"),
      day_of_week_i: Date.today.cwday
    }
  end

  def user_object
    if user && !user.nil?
      {
        user_id: user.id,
        user_type: user.try(:type),
        user_email: user.email,
        account_name: account_name,
        mls_credential: mls_credential
      }
    else
      nil
    end
  end

  def mls_credential
    return nil if user.nil?

    if user.try(:client?)
      client_mls_credential
    else
      user_mls_credential
    end
  end

  def client_mls_credential
    if user.agents.any? && !user.agents.first.mls_credential.nil?
      {
        code: user.agents.first.mls_credential.code,
        name: user.agents.first.mls_credential.name
      }
    else
      nil
    end
  end

  def user_mls_credential
    if !user.mls_credential.nil?
      {
        code: user.mls_credential.code,
        name: user.mls_credential.name
      }
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

end

