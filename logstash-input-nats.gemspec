Gem::Specification.new do |s|
  s.name = 'logstash-input-nats'
  s.version = '0.1.0'
  s.licenses = ['Apache License (2.0)']
  s.summary = "This example input streams a string at a definable interval."
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Jorge Madrid", "Michel Perez", "Angel Botto"]
  s.email = 'jlmadrid360@gmail.com', 'michel.ingsoft@gmail.com', 'angelbotto@gmail.com'
  s.homepage = "http://www.kreattiewe.com"
  s.require_paths = ["lib"]

  # Files
  s.files = `git ls-files`.split($\)
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_development_dependency 'logstash-devutils'

  # Jar dependencies
  s.requirements << "jar 'com.github.tyagihas:java_nats', '0.5.1'"
  s.add_runtime_dependency 'jar-dependencies'
end
