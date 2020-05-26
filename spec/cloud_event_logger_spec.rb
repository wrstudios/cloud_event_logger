RSpec.describe CloudEventLogger do
  require 'rspec/active_model/mocks'
  
  # Mock incoming user object from external apps
  let(:user) {  mock_model("User", id: 789, type: nil, email: 'test@gmail.com', account: account) }
  let(:agent) {  mock_model("User", type: 'Agent', id: 254, type: nil, email: 'test_1@gmail.com', account: account) }
  let(:client) {  mock_model("User",type: 'Client', id: 963, type: nil, email: 'test_2@gmail.com', account: account) }
  let(:account) { mock_model("Account", id: 987, name: "Test Broker Account")}
  let(:mls_credential) {  mock_model("MlsCredential", id: 564, code: 'crmls', name: 'California Realtors') }
  let(:mls) {  mock_model("Mls", id: 777, key: 'crmls', name: 'California') }

  context "when user type is Agent" do
    it "records event info" do
      allow(SecureRandom).to receive(:uuid).and_return('321')

      allow(agent).to receive(:try).with(:type).and_return('Agent')
      allow(agent).to receive(:try).with(:client?).and_return(false)
      allow(agent).to receive(:try).with(:agent?).and_return(true)
      allow(agent).to receive(:try).with(:account).and_return(account)
      allow(agent).to receive(:mls).and_return(mls)
      allow(agent).to receive(:mls_credential).and_return(mls_credential)

      allow(account).to receive(:try).with(:name).and_return(account.name)
      allow(account.name).to receive(:try).with(:upcase).and_return(account.name.upcase)
      

      if File.file?("spec/fixtures/test_agent.log")
        File.delete("spec/fixtures/test_agent.log") 
      end

      CloudEventLogger.config do |c|
        c.app_name = 'Cloud CMA'
        c.log_file = 'spec/fixtures/test_agent.log'
      end

      @time_now = Time.parse("2019-09-17 19:14:28 UTC")
      
      Timecop.freeze(@time_now) do
        metadata ={ foo: 'bar', 
                    biz: 'baz', 
                    mlsnum: '123456', 
                    lat:"-79.3716", 
                    lon:"43.6319"
                  }
        expect(CloudEventLogger.log_event(agent, 'Sign Up', metadata)).to eq(true)
        file1 = IO.read("spec/fixtures/test_agent.log")
        file2 = IO.read("spec/fixtures/event_logger_agent.log")
        expect(file1).to eq file2
      end
      File.delete("spec/fixtures/test_agent.log")
    end
  end

  context "when user type is Client" do
    it "records event info" do
      allow(SecureRandom).to receive(:uuid).and_return('321')

      allow(client).to receive(:try).with(:type).and_return('Client')
      allow(client).to receive(:try).with(:client?).and_return(true)
      allow(client).to receive(:try).with(:agent?).and_return(false)
      allow(client).to receive(:agents).and_return([agent])
      allow(client).to receive(:try).with(:account).and_return(nil)
      
      allow(agent).to receive(:mls_credential).and_return(mls_credential)
      allow(agent).to receive(:try).with(:account).and_return(account)
      allow(agent).to receive(:mls).and_return(mls)
      
      allow(account).to receive(:try).with(:name).and_return(account.name)
      allow(account.name).to receive(:try).with(:upcase).and_return(account.name.upcase)
      
      if File.file?("spec/fixtures/test_client.log")
        File.delete("spec/fixtures/test_client.log") 
      end

      CloudEventLogger.config do |c|
        c.app_name = 'Cloud CMA'
        c.log_file = 'spec/fixtures/test_client.log'
      end

      @time_now = Time.parse("2019-09-17 19:14:28 UTC")
      
      Timecop.freeze(@time_now) do
        metadata ={ foo: 'bar', 
                    biz: 'baz', 
                    mlsnum: '123456'
                  }
        expect(CloudEventLogger.log_event(client, 'Sign Up', metadata)).to eq(true)
        file1 = IO.read("spec/fixtures/test_client.log")
        file2 = IO.read("spec/fixtures/event_logger_client.log")
        expect(file1).to eq file2
      end
      File.delete("spec/fixtures/test_client.log")
    end
  end

  context "when user type is nil" do
    it "records event info" do
      allow(SecureRandom).to receive(:uuid).and_return('321')

      allow(user).to receive(:try).with(:type).and_return(nil)
      allow(user).to receive(:try).with(:client?).and_return(false)
      allow(user).to receive(:try).with(:agent?).and_return(nil)
      allow(user).to receive(:try).with(:account).and_return(account)
      allow(agent).to receive(:mls).and_return(mls)
      allow(user).to receive(:mls_credential).and_return(mls_credential)

      allow(account).to receive(:try).with(:name).and_return(account.name)
      allow(account.name).to receive(:try).with(:upcase).and_return(account.name.upcase)
      

      if File.file?("spec/fixtures/test_user.log")
        File.delete("spec/fixtures/test_user.log") 
      end

      CloudEventLogger.config do |c|
        c.app_name = 'Cloud CMA'
        c.log_file = 'spec/fixtures/test_user.log'
      end

      @time_now = Time.parse("2019-09-17 19:14:28 UTC")
      
      Timecop.freeze(@time_now) do
        metadata ={ foo: 'bar', 
                    biz: 'baz', 
                    mlsnum: '123456'
                  }
        expect(CloudEventLogger.log_event(user,'Sign Up', metadata)).to eq(true)
        file1 = IO.read("spec/fixtures/test_user.log")
        file2 = IO.read("spec/fixtures/event_logger_user.log")
        expect(file1).to eq file2
      end
      File.delete("spec/fixtures/test_user.log")
    end
  end

  it "has a version number" do
    expect(CloudEventLogger::VERSION).not_to be nil
  end

end
