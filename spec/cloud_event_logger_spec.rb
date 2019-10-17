RSpec.describe CloudEventLogger do
  require 'rspec/active_model/mocks'
  
  # Mock incoming user object from external apps
  let(:user) {  mock_model("User", id: 789, type: nil, email: 'test@gmail.com') }
  let(:mls_credential) {  mock_model("MlsCredintial", id: 564, code: 'crmls') }

  before do
    allow(SecureRandom).to receive(:uuid).and_return('321')
    allow(user).to receive(:try).and_return(false)
    allow(user).to receive(:mls_credential).and_return(mls_credential)
    # stub to_json call due to UUID on mock user object
    allow(user).to receive(:to_json).and_return('json')
  end

  it "has a version number" do
    expect(CloudEventLogger::VERSION).not_to be nil
  end

  it "records event info" do
    
    if File.file?("spec/fixtures/test.log")
      File.delete("spec/fixtures/test.log") 
    end

    CloudEventLogger.config do |c|
      c.app_name = 'Cloud CMA'
      c.log_file = 'spec/fixtures/test.log'
    end

    @time_now = Time.parse("2019-09-17 19:14:28 UTC")
    
    Timecop.freeze(@time_now) do
      metadata ={ foo: 'bar', 
                  biz: 'baz', 
                  mlsnum: '123456', 
                  proximity: "-79.3716, 43.6319"
                }
      expect(CloudEventLogger.log_event(user, 'Sign Up', metadata)).to eq(true)
      file1 = IO.read("spec/fixtures/test.log")
      file2 = IO.read("spec/fixtures/event_logger_test.log")
      expect(file1).to eq file2
    end

    File.delete("spec/fixtures/test.log")
  end
end
