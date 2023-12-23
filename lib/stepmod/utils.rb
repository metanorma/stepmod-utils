require "stepmod/utils/version"

module Stepmod
  module Utils
    class Error < StandardError; end

    @@eqn_log_dir = "."
    @@eqn_counter = 0

    def self.root
      File.expand_path("../..", __dir__)
    end

    def self.eqn_log_dir=(eqn_log_dir)
      @@eqn_log_dir = eqn_log_dir
    end

    def self.eqn_log_dir
      @@eqn_log_dir
    end

    def self.eqn_counter
      @@eqn_counter
    end

    def self.increment_eqn_counter
      @@eqn_counter += 1
    end
  end
end
