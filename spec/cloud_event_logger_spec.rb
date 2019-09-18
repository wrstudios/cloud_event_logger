RSpec.describe CloudEventLogger do

  before do
    allow(SecureRandom).to receive(:uuid).and_return('321')
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
      options = { event_name: 'Sign Up', 
            session_id: SecureRandom.uuid, 
            country: 'US',
            city: 'Huntington Beach',
            proximity: "-79.3716, 43.6319",
            metadata: { foo: 'bar', biz: 'baz', mlsnum: '123456'}
          }
      expect(CloudEventLogger.log_event(options)).to eq(true)
      file1 = IO.read("spec/fixtures/test.log")
      file2 = IO.read("spec/fixtures/event_logger_test.log")
      expect(file1).to eq file2
    end

    File.delete("spec/fixtures/test.log")
  end
end
