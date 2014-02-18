require 'singleton'
require 'git'
require 'fileutils'

class Packiz
  class Sync

    include Singleton

    def get_git
      if @git == nil
        token = ENV['GH_TOKEN']
        FileUtils.mkdir_p Packiz.instance.get_temp_path
        FileUtils.cd(Packiz.instance.get_temp_path) do
          @git = Git.clone('https://' + token + ':x-oauth-basic@github.com/Tim-B/language-test.git', 'language-test')
        end
      end
      @git
    end

    def get_repo_path
      get_git.dir.path
    end

    def task
      copy_files
      commit
      tag
      push
    end

    def match_files
      ['english.php', 'english/**']
    end

    def remove_files
      FileUtils.cd(get_repo_path) do
        match_files.each do |pattern|
          get_git.remove pattern
        end
      end
    end

    def add_files
      FileUtils.cd(get_repo_path) do
        match_files.each do |pattern|
          get_git.add pattern
        end
      end
    end

    def copy_files
      remove_files

      FileUtils.cd(Packiz.instance.get_src_root + '/inc/language') do
        Dir.glob('**/*').each do |file|
          if Packiz.instance.match_path(file, match_files)
            if File.directory?(file)
              FileUtils.mkdir_p get_repo_path + '/' + file
            else
              if !File.directory?(File.dirname(get_repo_path + '/' + file))
                FileUtils.mkdir_p File.dirname(get_repo_path + '/' + file)
              end
              FileUtils.cp file, get_repo_path + '/' + file
            end
          end
        end

        add_files
      end
    end

    def commit
      get_git.commit_all "Tagging: " + Packiz.instance.get_release_version
    end

    def tag
      get_git.lib.tag [Packiz.instance.get_release_version, '-f']
    end

    def push
      get_git.push 'origin', 'master', true
    end
  end
end
