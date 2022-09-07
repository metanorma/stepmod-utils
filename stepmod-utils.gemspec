require_relative "lib/stepmod/utils/version"

Gem::Specification.new do |spec|
  spec.name          = "stepmod-utils"
  spec.version       = Stepmod::Utils::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Stepmod-utils is a toolkit that works on STEPmod data."
  spec.description   = <<~DESCRIPTION
    Stepmod-utils is a toolkit that works on STEPmod data.
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
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "concurrent-ruby"
  spec.add_runtime_dependency "expressir"
  spec.add_runtime_dependency "glossarist", "~> 0.1.0"
  spec.add_runtime_dependency "indefinite_article"
  spec.add_runtime_dependency "ptools"
  spec.add_runtime_dependency "reverse_adoc", ">= 0.3.5"
  spec.add_runtime_dependency "thor", ">= 0.20.3"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
end
