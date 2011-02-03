Gem::Specification.new do |s|
  s.name     = 'kronic'
  s.version  = '1.1.2'
  s.summary  = 'A dirt simple library for parsing and formatting human readable dates'
  s.platform = Gem::Platform::RUBY
  s.authors  = ["Xavier Shay"]
  s.email    = ["hello@xaviershay.com"]
  s.homepage = "http://github.com/xaviershay/kronic"
  s.has_rdoc = false

  s.require_path = 'lib'
  s.files        = Dir.glob("{spec,lib}/**/*.rb") + 
                   Dir.glob("{spec,lib}/**/*.js") +
                   %w(
                     Gemfile 
                     Gemfile.lock 
                     README.rdoc 
                     HISTORY 
                     Rakefile 
                     .gemtest 
                     kronic.gemspec
                   )

  s.add_development_dependency 'rspec', '~> 2.0.1'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'tzinfo'
end

