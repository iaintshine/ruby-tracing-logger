require "spec_helper"

RSpec.describe Tracing::CompositeLogger do
  let(:tracer) { Test::Tracer.new }

  describe "initialization" do
    it "allows to set multiple destination loggers" do
      expect(Tracing::CompositeLogger.new(TestLogger.new, TestLogger.new).destinations.size).to eq(2)
    end
  end

  describe :add do
    it "calls each of the destinations" do
      logger = Tracing::CompositeLogger.new(TestLogger.new, TestLogger.new)
      logger.add(::Logger::DEBUG, "debug message", "progname")
      logger.destinations.each do |destination|
        expect(destination.logs.size).to eq(1)

        log = destination.logs.first
        expect(log.severity).to eq(::Logger::DEBUG)
        expect(log.message).to eq("debug message")
        expect(log.progname).to eq("progname")
      end
    end
  end


  class TestLogger < ::Logger
    attr_reader :logs

    class LogEntry < Struct.new(:severity, :message, :progname); end

    def initialize
      super(nil)
      @logs = []
    end

    def add(severity, message = nil, progname = nil)
      @logs << LogEntry.new(severity, message, progname)
      true
    end
  end
end
