# frozen_striing_literal: true

class StringWithoutIndent < Shale::Type::Value
  def self.cast(value)
    value&.gsub(/[ \t]/, "")
  end
end
