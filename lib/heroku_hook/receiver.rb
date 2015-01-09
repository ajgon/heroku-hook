require 'git'

module HerokuHook
  # This class is responsible for receiving post-receive hook and passing it along
  # :reek:ClassVariable
  # rubocop:disable Style/ClassVars
  class Receiver
    def self.handle(repo_path)
      @@repo_path = repo_path
      @@bare = false
      @@git = init_repo(@@repo_path)
      Config.project_name = File.basename(@@repo_path).sub(/\.git$/, '')
      self
    end

    def self.bare?
      @@bare
    end

    def self.repo_path
      @@repo_path
    end

    def self.init_repo(path)
      Git.open(path)
    rescue
      @@bare = true
      bare = Git.bare(path)
      bare if bare.ls_files
    end
  end
  # rubocop:enable Style/ClassVars
end
