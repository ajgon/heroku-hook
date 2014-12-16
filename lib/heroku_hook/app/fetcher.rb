require 'git'
module HerokuHook
  module App
    # Fetches repo from receiver path and prepares it for buildpacks
    class Fetcher < HerokuHook::App::Base
      attr_reader :app_path, :cache_path, :env_path

      def prepare
        [@app_path, @cache_path, @env_path].each do |path|
          FileUtils.rm_rf(path) if path == @app_path
          FileUtils.mkdir_p(path)
        end
      end

      def clone
        Git.export(@receiver.repo_path, @app_path)
      end

      def run
        HerokuHook::Display.out 'Fetching repository, '
        prepare
        clone
        HerokuHook::Display.raw_outln 'done.'
        true
      end
    end
  end
end
