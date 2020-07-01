require_relative 'lib/stepmod/utils/version'

Gem::Specification.new do |spec|
  spec.name          = "stepmod-utils"
  spec.version       = Stepmod::Utils::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "stepmod-utils converts NISO STS XML into Metanorma XML."
  spec.description   = <<~DESCRIPTION
    stepmod-utils converts NISO STS XML into Metanorma XML.
    This gem is a wrapper around stepmod-utils.jar available from
    https://github.com/metanorma/stepmod-utils, with versions matching the JAR file.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/stepmod-utils"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 1.0"
  spec.add_runtime_dependency "reverse_adoc", "~> 0.2"
end
