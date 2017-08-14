module Tracing
  class CompositeLogger < ::Logger
    attr_reader :destinations

    def initialize(*loggers)
      super(nil)
      @destinations = loggers
    end

    def add(*args, &block)
      @destinations.each { |logger| logger.add(*args, &block) }
    end
  end
end
