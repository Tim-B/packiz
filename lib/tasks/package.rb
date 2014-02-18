require 'singleton'
require 'fileutils'
require 'zip'
require 'erb'

class Packiz
  class Package

    include Singleton

    def task
      make_full_package
    end

    def get_package_name_path
      path = Packiz.instance.get_temp_path + '/' + MyApp.instance.get_package_name
    end

    def copy_src_files
      package_path = 'build/' + get_package_name_path + '/' + MyApp.instance.config['src']['dest']
      FileUtils.cd(Packiz.instance.get_src_root) do
        FileUtils.mkdir_p package_path
        Dir.glob('**/*').each do |file|
          if !Packiz.instance.match_path(file, src_ignore)
            if File.directory?(file)
              FileUtils.mkdir_p package_path + '/' + file
            else
              FileUtils.cp file, package_path + '/' + file
            end
          end
        end
      end

    end

    def make_full_package
      copy_src_files
      move_files
      replace_file_content
      create_archive(
          get_package_name_path + '/',
          MyApp.instance.get_archive_path
      )
    end

    def src_ignore
      Packiz.instance.config['src']['ignore']
    end

    def create_archive(src_dir, dest)
      puts 'Creating release archive: ' + dest
      Zip::File.open(dest, Zip::File::CREATE) do |zipfile|
        Dir[File.join(src_dir, '**', '**')].each do |file|
          zipfile.add(file.sub(src_dir, ''), file)
        end
      end
    end

    def move_files
      moves = Packiz.instance.config['move']
      moves.each do |move|
        src = get_package_name_path + '/' + move['src']
        dest = get_package_name_path + '/' + move['dest']
        FileUtils.mv src, dest
      end
    end

    def replace_file_content
      replace = Packiz.instance.config['content_replace']
      replace.each do |rep|
        file = get_package_name_path + '/' + rep['file']
        replaced_text = ERB.new(rep['replace']).result
        find = rep['find']
        text = File.read(file)
        text = text.sub(find, replaced_text)
        File.open(file, 'w') {|content| content.puts text}
      end
    end

  end
end

