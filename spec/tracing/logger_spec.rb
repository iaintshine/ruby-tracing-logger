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

        expect(span).not_to have_logs
      end
    end

    context "severity of the message >= then logger's level" do
      let(:logger) { Tracing::Logger.new(active_span: active_span, level: ::Logger::DEBUG) }

      it "returns true" do
        expect(logger.add(::Logger::DEBUG, "test message")).to eq(true)
      end

      it "logs the message" do
        logger.add(::Logger::DEBUG, "test message")

        expect(span).to have_logs
      end

      it "fills up log entry with proper attributes" do
        logger.add(::Logger::DEBUG, "test message", "test progname")

        expect(span).to have_log(event: "test message", severity: "DEBUG", progname: "test progname")
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

        expect(span).to have_log(event: "s: DEBUG, pid: ##{$$}, progname: test progname, msg: test message")
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
