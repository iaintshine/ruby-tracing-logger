require "spec_helper"

RSpec.describe Tracing::Logger do
  let(:tracer) { Test::Tracer.new }

  describe "logger initialization" do
    let(:span) { OpenTracing::Span.new }
    let(:active_span) { -> { span } }

    it "allows to set active_span provider" do
      expect(Tracing::Logger.new(active_span: active_span).active_span).to eq(span)
    end

    it "sets default level to DEBUG" do
      expect(Tracing::Logger.new(active_span: active_span).level).to eq(::Logger::DEBUG)
    end

    it "allows to set level" do
      expect(Tracing::Logger.new(active_span: active_span, level: ::Logger::ERROR).level).to eq(::Logger::ERROR)
    end
  end

  describe :add do
    let(:span) { tracer.start_span("root") }
    let(:active_span) { -> { span } }

    context "severity of the message lower then logger's level" do
      let(:logger) { Tracing::Logger.new(active_span: active_span, level: ::Logger::ERROR) }

      it "returns true" do
        expect(logger.add(::Logger::DEBUG, "test message")).to eq(true)
      end

      it "doesn't log the message" do
        logger.add(::Logger::DEBUG, "test message")

        expect(span.logs).to be_empty
      end
    end

    context "severity of the message >= then logger's level" do
      let(:logger) { Tracing::Logger.new(active_span: active_span, level: ::Logger::DEBUG) }

      it "returns true" do
        expect(logger.add(::Logger::DEBUG, "test message")).to eq(true)
      end

      it "logs the message" do
        logger.add(::Logger::DEBUG, "test message")

        expect(span.logs).not_to be_empty
      end

      it "fills up log entry with proper attributes" do
        logger.add(::Logger::DEBUG, "test message", "test progname")

        log = span.logs.first
        expect(log.event).to eq("test message")
        expect(log.fields[:severity]).to eq("DEBUG")
        expect(log.fields[:progname]).to eq("test progname")
      end

      it "understands severity levels well" do
        severities = [:debug, :info, :warn, :error, :fatal, :unknown]
        severities.each do |severity|
          logger.send(severity, "#{severity} message")
        end

        expect(span.logs.size).to eq(severities.size)
      end

      it "allows to customize formatter" do
        logger.formatter = TestFormatter.new

        logger.add(::Logger::DEBUG, "test message", "test progname")

        log = span.logs.first
        expect(log.event).to eq("s: DEBUG, pid: ##{$$}, progname: test progname, msg: test message")
      end
    end
  end

  class TestFormatter
    Format = "s: %s, pid: #%d, progname: %s, msg: %s".freeze

    def call(severity, time, progname, msg)
      Format % [severity, $$, progname, msg]
    end
  end
end
