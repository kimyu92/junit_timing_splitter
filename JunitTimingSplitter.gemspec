Gem::Specification.new do |spec|
  spec.name          = 'junit_timing_splitter'
  spec.version       = '1.1.0'
  spec.summary       = 'Split test files into evenly distributed buckets based on execution time'
  spec.description   = 'A tool to optimize parallel test execution by analyzing JUnit XML results and distributing test files across buckets.'
  spec.author        = 'Kim Yu Ng'
  spec.email         = 'kimyu92@gmail.com'
  spec.files         = Dir['lib/**/*.rb']
  spec.homepage      = 'https://github.com/kimyu92/junit_timing_splitter'
  spec.license       = 'MIT'

  spec.metadata['bug_tracker_uri'] = 'https://github.com/kimyu92/junit_timing_splitter/issues'
  spec.metadata['documentation_uri'] = 'https://github.com/kimyu92/junit_timing_splitter/blob/main/README.md'
  spec.metadata['changelog_uri'] = 'https://github.com/kimyu92/junit_timing_splitter/blob/main/CHANGELOG.md'

  spec.files = Dir["lib/**/*.rb"]
  spec.bindir = "bin"
  spec.executables   = ["junit_timing_splitter"]
  spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ['>= 3.1', '< 4.0']

  spec.add_runtime_dependency 'nokogiri', ['>= 1.15', '< 2.0']
  spec.add_runtime_dependency "thor", "~> 1.0"
  spec.add_runtime_dependency 'json', '~> 2.1', '>= 2.1.0'
  spec.add_dependency "zeitwerk", ['>= 2.4', '< 3.0']
end
