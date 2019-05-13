require 'spec_helper'

describe NewspaperWorks::Logging do
  describe "mixin logging module" do
    let(:klass) do
      Class.new do
        include NewspaperWorks::Logging
      end
    end

    let(:loggable) { klass.new }

    let(:configured) do
      obj = loggable
      # expectation is that this is called by consuming class constructor:
      obj.configure_logger('ingest-test')
      obj
    end

    it "requires configuration by consuming class" do
      expect(loggable.instance_variable_get(:@logger)).to be_nil
      loggable.configure_logger('random_testing_logname')
      expect(loggable.instance_variable_get(:@logger)).not_to be_nil
    end

    it "logs formatted message to rails logger with write_log" do
      message = "FYI: heads-up, this is a message"
      expect(Rails.logger).to receive(:add).with(
        Logger::INFO,
        configured.message_format(message),
        nil
      )
      configured.write_log(message)
    end

    it "writes to named log file" do
      message = "Instant coffee"
      named_log = configured.instance_variable_get(:@named_log)
      expect(named_log).not_to be_nil
      expect(named_log).to receive(:add).with(
        Logger::INFO,
        configured.message_format(message),
        nil
      )
      configured.write_log(message)
    end
  end
end
