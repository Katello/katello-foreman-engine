source "https://rubygems.org"

gemspec

KATELLO_GEMFILE=File.expand_path('../test/katello_app/Gemfile', __FILE__)
unless File.exist?(KATELLO_GEMFILE)
  puts <<MESSAGE
Foreman source code is not present. To get the latest version, run:

  rake test:katello_prepare

and try again.
MESSAGE

else
  self.instance_eval(Bundler.read_file(KATELLO_GEMFILE))
end

