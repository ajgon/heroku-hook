require 'git'
module HerokuHook
  module Repo
    # Fetches repo from receiver path and prepares it for buildpacks
    class Fetcher
      attr_reader :app_path, :cache_path, :env_path

      def initialize(receiver, config)
        @receiver, @config = receiver, config
        %w(app cache env).each do |dir|
          instance_variable_set("@#{dir}_path",
                                File.join(@config.projects_base_path, @receiver.name, @config.dirs.send(dir)))
        end
      end

      def prepare
        [@app_path, @cache_path, @env_path].each do |path|
          FileUtils.rm_rf(path) if path == @app_path
          FileUtils.mkdir_p(path)
        end
      end

      def clone
        Git.export(@receiver.repo_path, @app_path)
      end

      def build
        prepare
        clone
      end
    end
  end
end
