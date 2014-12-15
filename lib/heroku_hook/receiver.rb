require 'git'

module HerokuHook
  # This class is responsible for receiving post-receive hook and passing it along
  class Receiver
    attr_reader :bare
    attr_reader :repo_path
    alias_method :bare?, :bare

    def initialize(repo_path)
      @repo_path = repo_path
      @bare = false
      @git = init_repo(@repo_path)
    end

    def name
      File.basename(@repo_path).sub(/\.git$/, '')
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
