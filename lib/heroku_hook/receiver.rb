require 'git'

module HerokuHook
  # This module is responsible for receiving post-receive hook and passing it along
  class Receiver
    attr_reader :bare, :repo_path
    alias_method :bare?, :bare

    def initialize(repo_path)
      @repo_path = repo_path
      @bare = false
      @git = init_repo(@repo_path)
      Config.project_name, Config.repo_path = File.basename(@repo_path).sub(/\.git$/, ''), @repo_path
    end

    private

    def init_repo(path)
      Git.open(path)
    rescue
      @bare = true
      bare = Git.bare(path)
      bare if bare.ls_files
    end
  end
end
