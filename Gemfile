source 'https://rubygems.org'

platforms(:mri) do # This should exclude rbx, but doesn't in my testing
  gem 'therubyracer' #, '>= 0.8.0.pre2' unless Kernel.const_defined?(:RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
end

gemspec
