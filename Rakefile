require './lib/packiz.rb'
require './lib/tasks/package.rb'
require './lib/tasks/clean.rb'
require './lib/tasks/release.rb'
require './lib/tasks/sync.rb'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :packiz do

  desc 'Builds release packages and puts them in the release folder'
  task :package => [:clean] do
    Packiz::Package.instance.task
  end

  desc 'Deploys the release packages to GitHub'
  task :release => [:package] do
    Packiz::Release.instance.task
    if MyApp.instance.is_tag?
      Packiz::Sync.instance.task
    end
  end

  desc 'Cleans generated release packages'
  task :clean do
    Packiz::Clean.instance.task
  end

  desc 'Syncs any dependant repositories with current repository version'
  task :sync => [:clean] do
    Packiz::Sync.instance.task
  end

end