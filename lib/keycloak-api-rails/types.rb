module Keycloak
  module Types
    include Dry.Types

    Timestamp = Types.Constructor(::Time) do |value|
      case value
      when Integer then ::Time.at(value)
      when ::Time then value
      when Types.Interface(:to_time) then value.to_time
      end
    end.optional
  end
end
