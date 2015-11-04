source 'https://rubygems.org'
gemspec

gem 'rake'

# Useful for dev and debug, but not mandatory to run the test suite, so omitted
# on CI because they slow the build.
group :ciskip do
  gem 'ruby-debug',   :platforms => :mri_18
  gem 'ruby-debug19', :platforms => :mri_19, :require => 'ruby-debug'
  gem 'yard'
end
