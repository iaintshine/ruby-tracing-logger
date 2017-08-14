module Tracing
  class CompositeLogger < ::Logger
    def initialize(*loggers)
      super(nil)
      @loggers = loggers
    end

    def add(*args, &block)
      @loggers.each { |logger| logger.add(*args, &block) }
    end
  end
end
