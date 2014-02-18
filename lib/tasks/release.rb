require 'singleton'
require 'github_api'

class Packiz
  class Release

    include Singleton

    def task
      @user = 'Tim-B'
      @repo = 'tag-test'

      version = Packiz.instance.get_release_version

      packages = Array.new

      release = create_or_get_release version

      full_package = Packiz::Release::ReleasePackage.new
      full_package.version = version
      full_package.release_id = release.id
      full_package.file_name = Packiz.instance.get_archive_name
      full_package.file_path = Packiz.instance.get_archive_path
      test_preconditions full_package
      packages.push full_package

      packages.each do |package|
        create_or_update_asset package
      end

    end

    def get_gh_api
      if @gh_api == nil
        @gh_api = Github.new do |config|
          config.oauth_token = ENV['GH_TOKEN']
        end
      end
      @gh_api
    end

    def test_preconditions(package)
      if !File.exists? package.file_path
        abort('Aborting: Release archive does not exist')
      end
    end

    def get_release(tag)
      releases = get_gh_api.repos.releases.list @user, @repo
      releases.each do |release|
        if release.tag_name == tag
          return release
        end
      end
      return nil
    end

    def create_or_get_release (version)
      release = get_release version
      if release == nil
        release = create_release version
      end
      release
    end

    def create_release(tag)
      get_gh_api.repos.releases.create(@user, @repo, tag,
                                       :name => 'Release: ' + tag,
                                       :tag_name => 'v1.0.0',
                                       :target_commitish => 'master',
                                       :body => 'Release: ' + tag,
                                       :draft => false,
                                       :prerelease => true
      )
    end


    def create_or_update_asset(package)
      asset = get_asset package
      if asset != nil
        delete_asset asset
      end
      upload_asset package
    end


    def get_asset(package)
      packages = get_gh_api.repos.releases.assets.list @user, @repo, package.release_id do |asset|
        if asset.name == package.file_name
          return asset
        end
      end
      return nil
    end

    def upload_asset(package)
      get_gh_api.repos.releases.assets.upload(@user, @repo, package.release_id, package.file_path,
                                              :name => package.file_name,
                                              :content_type => 'application/zip'
      )
    end

    def delete_asset(asset)
      get_gh_api.repos.releases.assets.delete(@user, @repo, asset.id)
    end

    def sync_external_repos

    end

    class ReleasePackage
      attr_accessor :version, :file_name, :file_path, :release_id
    end

  end
end

