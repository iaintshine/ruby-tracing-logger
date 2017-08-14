require 'opentracing'
require 'logger'

require_relative 'type_check'
require_relative 'composite_logger'

module Tracing
  class Logger < ::Logger
    include TypeCheck

    def initialize(active_span:, level: DEBUG)
      Type! active_span, Proc

      super(nil)
      @active_span = active_span
      self.level = level
    end

    def add(severity, message = nil, progname = nil)
      severity ||= Logger::Severity::UNKNOWN

      if severity < @level
        return true
      end

      if progname.nil?
        progname = @progname
      end

      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end

      span = active_span

      if span && message
        if @formatter
          span.log(event: format_message(format_severity(severity), Time.now, progname, message))
        else
          span.log(event: message, severity: format_severity(severity), progname: progname, pid: $$)
        end
      end

      true
    end

    def active_span
      @active_span&.call
    end
  end
end
