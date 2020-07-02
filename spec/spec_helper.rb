require "bundler/setup"
require 'byebug'
require "stepmod/utils"
require 'stepmod/utils/stepmod_definition_converter'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def node_for(html)
  Nokogiri::HTML.parse(html).root.child.child
end
