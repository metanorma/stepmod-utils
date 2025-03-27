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
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

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

  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "coradoc", "~> 1.1.7"
  spec.add_dependency "down"
  spec.add_dependency "expressir"
  spec.add_dependency "glossarist", "~> 2.0"
  spec.add_dependency "indefinite_article"
  spec.add_dependency "octokit"
  spec.add_dependency "plurimath"
  spec.add_dependency "ptools"
  spec.add_dependency "pubid-iso"
  spec.add_dependency "shale"
  spec.add_dependency "thor", ">= 0.20"
  spec.add_dependency "unitsml"
end
