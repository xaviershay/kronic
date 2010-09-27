Gem::Specification.new do |s|
  s.name = 'kronic'
  s.version = '0.3'
  s.summary = 'A dirt simple library for parsing human readable dates'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Xavier Shay"]
  s.email       = ["hello@xaviershay.com"]
  s.homepage    = "http://github.com/xaviershay/kronic"
  s.has_rdoc = false

  s.files        = Dir.glob("{spec,lib}/**/*") + %w(README.rdoc HISTORY Rakefile)
  s.require_path = 'lib'

  s.add_development_dependency 'rspec', '>= 2.0.0.beta.16'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'tzinfo'
end

