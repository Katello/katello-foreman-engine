ENGINE_DIR = File.expand_path('..', __FILE__)
KATELLO_DIR = 'test/katello_app'
require 'fileutils'

namespace :test do
  desc "Download latest katello devel source and install dependencies"
  task :katello_prepare do
    katello_repo = 'https://github.com/Katello/katello.git'
    katello_gemfile = File.join(KATELLO_DIR, "Gemfile")
    unless File.exists?(katello_gemfile)
      puts "Katello source code is not present at #{KATELLO_DIR}"
      puts "Downloading latest Katello development branch into #{KATELLO_DIR}..."
      FileUtils.mkdir_p(KATELLO_DIR)

      unless system("git clone #{katello_repo} #{KATELLO_DIR}")
        puts "Error while getting latest Katello code from #{katello_repo} into #{KATELLO_DIR}"
        fail
      end
    end

    gemfile_content = File.read(katello_gemfile)
    unless gemfile_content.include?('KATELLO_GEMFILE')
      puts 'Preparing Gemfile'
      gemfile_content.gsub!('__FILE__', 'KATELLO_GEMFILE')
      gemfile_content.insert(0, "KATELLO_GEMFILE = __FILE__ unless defined? KATELLO_GEMFILE\n")
      File.open(katello_gemfile, 'w') { |f| f << gemfile_content }
    end

    settings_file = "#{KATELLO_DIR}/config/katello.yml"
    unless File.exists?(settings_file)
      puts 'Preparing settings file'
      File.open(settings_file, "w") { |f| f << <<SETTINGS }
common:
  foreman:
    url: https://localhost/foreman/

SETTINGS
    end

    ["#{ENGINE_DIR}/.bundle/config", "#{KATELLO_DIR}/.bundle/config"].each do |bundle_file|
      unless File.exists?(bundle_file)
        FileUtils.mkdir_p(File.dirname(bundle_file))
        puts 'Preparing bundler configuration'
        File.open(bundle_file, 'w') { |f| f << <<FILE }
BUNDLE_WITHOUT: assets:checking:debugging:development_boost:optional
FILE
      end
    end

    puts 'Installing dependencies...'
    unless system('bundle install')
      fail
    end
  end

  task :db_prepare do
    unless File.exists?(KATELLO_DIR)
      puts <<MESSAGE
Katello source code not prepared. Run

  rake test:katello_prepare

to download katello source and its dependencies
MESSAGE
      fail
    end

    # once we are Ruby19 only, switch to block variant of cd
    pwd = FileUtils.pwd
    FileUtils.cd(KATELLO_DIR)
    unless system('rake db:test:prepare RAILS_ENV=test')
      puts "Migrating database first"
      system('rake db:create db:migrate db:schema:dump db:test:prepare RAILS_ENV=test') || fail
    end
    FileUtils.cd(pwd)
  end

  task :set_loadpath do
    %w[lib test].each do |dir|
      $:.unshift(File.expand_path(dir, ENGINE_DIR))
    end
  end

  task :all => [:db_prepare, :set_loadpath] do
    Dir.glob('test/**/*_test.rb') { |f| require f.sub('test/','')  unless f.include? '/katello_app/' }
  end

end

task :test => 'test:all'
