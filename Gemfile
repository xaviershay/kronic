source :rubygems

platforms(:mri) do # This should exclude rbx, but doesn't in my testing
  gem 'therubyracer', '>= 0.8.0.pre2' unless RUBY_ENGINE == 'rbx'
end

gemspec
