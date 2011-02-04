require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc 'Default: run specs.'
task :default => :spec

task :test => :spec do
  `jsl -nologo -process lib/js/kronic.js"` if `which jsl`.length > 0
end
