Gem::Specification.new do |s|
  s.name     = 'kronic'
  s.version  = '1.1.3'
  s.summary  = 'A dirt simple library for parsing and formatting human readable dates'
  s.platform = Gem::Platform::RUBY
  s.authors  = ["Xavier Shay"]
  s.email    = ["contact@xaviershay.com"]
  s.homepage = "http://github.com/xaviershay/kronic"
  s.has_rdoc = false

  s.require_path = 'lib'
  s.files        = Dir.glob("{spec,lib}/**/*.rb") + 
                   Dir.glob("{spec,lib}/**/*.js") +
                   %w(
                     Gemfile 
                     README.rdoc 
                     HISTORY 
                     Rakefile 
                     .gemtest 
                     kronic.gemspec
                   )

  s.add_development_dependency 'xspec'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'i18n'
  s.add_development_dependency 'tzinfo'
  s.add_development_dependency 'bundler'
end

