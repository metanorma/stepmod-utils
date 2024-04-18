# frozen_striing_literal: true

class StringWithoutIndent < Shale::Type::Value
  def self.cast(value)
    return unless value

    value.split("\n").map(&:strip).join("\n")
  end
end
