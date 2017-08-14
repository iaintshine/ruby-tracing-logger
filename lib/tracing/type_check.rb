module Tracing
  module TypeCheck
    class NullError < StandardError; end

    def Type?(value, *types)
      types.any? { |t| value.is_a? t }
    end

    def Type!(value, *types)
      Type?(value, *types) or
        raise TypeError, "Value (#{value.class}) '#{value}' is not any of: #{types.join('; ')}."
      value
    end
  end
end
