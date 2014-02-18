require 'fileutils'
require 'singleton'

class Packiz
  class Clean

    include Singleton

    def task
      FileUtils.rm_rf(Dir.glob(MyApp.instance.get_release_path + '/*'))
      FileUtils.touch MyApp.instance.get_release_path + '/.gitkeep'
      puts '=== release directory cleaned ==='
    end
  end
end
